import Foundation
import Observation
import StoreKit

struct PurchaseEntitlement: Equatable, Sendable {
    let productID: String
    let expirationDate: Date?
}

private enum PurchaseManagerError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "We could not verify this purchase. Please try restoring purchases."
        }
    }
}

@MainActor
@Observable
final class PurchaseManager {
    nonisolated static let annualProductID = "whitebrew.annual"
    nonisolated static let lifetimeProductID = "whitebrew.lifetime"

    nonisolated private static let productIDs = [annualProductID, lifetimeProductID]

    var products: [Product] = []
    var membershipState: MembershipState = .free
    var isLoading = false
    var errorMessage: String?

    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedProducts = try await Product.products(for: Self.productIDs)
            products = loadedProducts.sorted { first, second in
                Self.sortIndex(for: first.id) < Self.sortIndex(for: second.id)
            }
        } catch {
            errorMessage = "Unable to load membership products. Please try again."
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                await updateEntitlements()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                errorMessage = "Purchase could not be completed. Please try again."
            }
        } catch let error as PurchaseManagerError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Purchase could not be completed. Please try again."
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateEntitlements()
        } catch let error as PurchaseManagerError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Unable to restore purchases. Please try again."
        }
    }

    func refreshEntitlements() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await updateEntitlements()
    }

    func checkVerified<Value>(_ result: VerificationResult<Value>) throws -> Value {
        switch result {
        case .verified(let value):
            value
        case .unverified:
            throw PurchaseManagerError.failedVerification
        }
    }

    nonisolated static func membershipState(
        for entitlements: [PurchaseEntitlement],
        asOf date: Date = .now
    ) -> MembershipState {
        if entitlements.contains(where: { $0.productID == lifetimeProductID }) {
            return .lifetime
        }

        var hasOpenAnnual = false
        var latestAnnualExpiration: Date?

        for entitlement in entitlements where entitlement.productID == annualProductID {
            guard let expirationDate = entitlement.expirationDate else {
                hasOpenAnnual = true
                continue
            }

            guard expirationDate > date else {
                continue
            }

            if latestAnnualExpiration.map({ expirationDate > $0 }) ?? true {
                latestAnnualExpiration = expirationDate
            }
        }

        if hasOpenAnnual {
            return .annual(expiresAt: nil)
        }

        if let latestAnnualExpiration {
            return .annual(expiresAt: latestAnnualExpiration)
        }

        return .free
    }

    private func updateEntitlements() async {
        var entitlements: [PurchaseEntitlement] = []

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                entitlements.append(
                    PurchaseEntitlement(
                        productID: transaction.productID,
                        expirationDate: transaction.expirationDate
                    )
                )
            } catch let error as PurchaseManagerError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "We could not verify your purchases. Please try restoring purchases."
            }
        }

        membershipState = Self.membershipState(for: entitlements)
    }

    nonisolated private static func sortIndex(for productID: String) -> Int {
        productIDs.firstIndex(of: productID) ?? productIDs.count
    }
}
