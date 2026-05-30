import XCTest
@testable import WhiteBrew

final class PurchaseManagerTests: XCTestCase {
    func testLifetimeMembershipIsActive() {
        XCTAssertTrue(MembershipState.lifetime.isMember)
    }

    func testFreeMembershipIsInactive() {
        XCTAssertFalse(MembershipState.free.isMember)
    }

    func testFutureAnnualMembershipIsActiveAsOfDate() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let state = MembershipState.annual(expiresAt: now.addingTimeInterval(3600))

        XCTAssertTrue(state.isMember(asOf: now))
    }

    func testExpiredAnnualMembershipIsInactiveAsOfDate() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let state = MembershipState.annual(expiresAt: now.addingTimeInterval(-3600))

        XCTAssertFalse(state.isMember(asOf: now))
    }

    func testEntitlementReducerAppliesLifetimeMembership() {
        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.lifetimeProductID,
                    expirationDate: nil
                )
            ],
            asOf: Date(timeIntervalSinceReferenceDate: 800_000_000)
        )

        XCTAssertEqual(state, .lifetime)
    }

    func testEntitlementReducerAppliesFutureAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let expirationDate = now.addingTimeInterval(3600)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: expirationDate
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .annual(expiresAt: expirationDate))
    }

    func testEntitlementReducerIgnoresExpiredAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: now.addingTimeInterval(-3600)
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .free)
    }

    func testEntitlementReducerPrefersLifetimeOverAnnualMembership() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: now.addingTimeInterval(3600)
                ),
                PurchaseEntitlement(
                    productID: PurchaseManager.lifetimeProductID,
                    expirationDate: nil
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .lifetime)
    }

    func testEntitlementReducerUsesLatestActiveAnnualExpiration() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let earlierExpiration = now.addingTimeInterval(3600)
        let laterExpiration = now.addingTimeInterval(7200)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: earlierExpiration
                ),
                PurchaseEntitlement(
                    productID: PurchaseManager.annualProductID,
                    expirationDate: laterExpiration
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .annual(expiresAt: laterExpiration))
    }

    func testEntitlementReducerIgnoresUnknownProductIDs() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.membershipState(
            for: [
                PurchaseEntitlement(
                    productID: "whitebrew.tip",
                    expirationDate: nil
                )
            ],
            asOf: now
        )

        XCTAssertEqual(state, .free)
    }

    func testProductPurchaseStateMarksActiveAnnualAsCurrent() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.purchaseState(
            for: PurchaseManager.annualProductID,
            membershipState: .annual(expiresAt: now.addingTimeInterval(3600)),
            asOf: now
        )

        XCTAssertEqual(state, .current)
    }

    func testProductPurchaseStateKeepsLifetimePurchasableForAnnualMembers() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        let state = PurchaseManager.purchaseState(
            for: PurchaseManager.lifetimeProductID,
            membershipState: .annual(expiresAt: now.addingTimeInterval(3600)),
            asOf: now
        )

        XCTAssertEqual(state, .purchasable)
    }

    func testProductPurchaseStateDisablesProductsForLifetimeMembers() {
        XCTAssertEqual(
            PurchaseManager.purchaseState(
                for: PurchaseManager.lifetimeProductID,
                membershipState: .lifetime
            ),
            .current
        )
        XCTAssertEqual(
            PurchaseManager.purchaseState(
                for: PurchaseManager.annualProductID,
                membershipState: .lifetime
            ),
            .active
        )
    }

    func testProductPurchaseStateIgnoresUnknownProductIDs() {
        XCTAssertEqual(
            PurchaseManager.purchaseState(
                for: "whitebrew.tip",
                membershipState: .lifetime
            ),
            .unavailable
        )
    }
}
