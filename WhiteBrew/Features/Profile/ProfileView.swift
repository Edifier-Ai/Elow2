import StoreKit
import SwiftData
import SwiftUI

struct ProfileView: View {
    @Query(sort: \DrinkRecord.updatedAt, order: .reverse) private var records: [DrinkRecord]
    @Environment(PurchaseManager.self) private var purchaseManager

    private var pendingCount: Int {
        records.filter { $0.syncState == .pendingUpload }.count
    }

    private var visibleCount: Int {
        records.filter { $0.deletedAt == nil }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    membership
                    syncAndData
                    legal
                }
                .padding(20)
            }
            .background(ClayTheme.background.ignoresSafeArea())
        }
    }

    private var header: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Me")
                        .font(.largeTitle.bold())
                        .foregroundStyle(ClayTheme.text)
                    Text("Account, membership, sync, and local data controls.")
                        .font(.subheadline)
                        .foregroundStyle(ClayTheme.secondaryText)
                }

                ClayButton("Sign in", systemImage: "person.crop.circle.badge.plus") {}
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var membership: some View {
        claySection("Membership") {
            settingsRow(symbol: "crown", title: "Current plan", subtitle: membershipSubtitle)

            if purchaseManager.isLoading {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Loading membership")
                        .font(.caption)
                        .foregroundStyle(ClayTheme.secondaryText)
                }
                .padding(.vertical, 6)
            }

            if purchaseManager.products.isEmpty && !purchaseManager.isLoading {
                settingsRow(symbol: "sparkles", title: "Premium plans", subtitle: "Products unavailable")
            } else {
                ForEach(purchaseManager.products) { product in
                    productRow(product)
                }
            }

            ClayButton("Restore purchases", systemImage: "arrow.clockwise") {
                Task {
                    await purchaseManager.restorePurchases()
                }
            }
            .disabled(purchaseManager.isLoading)

            if let errorMessage = purchaseManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.top, 2)
            }
        }
    }

    private var syncAndData: some View {
        claySection("Sync and Data") {
            settingsRow(
                symbol: "icloud.and.arrow.up",
                title: "Sync status",
                subtitle: pendingCount == 0 ? "\(visibleCount) local records, no pending uploads" : "\(pendingCount) pending upload"
            )
            settingsRow(symbol: "square.and.arrow.up", title: "Export data", subtitle: "Local file export placeholder")
            settingsRow(symbol: "square.and.arrow.down", title: "Import data", subtitle: "Local file import placeholder")
        }
    }

    private var legal: some View {
        claySection("Privacy") {
            settingsRow(symbol: "hand.raised", title: "Privacy policy", subtitle: "Draft route placeholder")
            settingsRow(symbol: "doc.text", title: "Terms of use", subtitle: "Draft route placeholder")
        }
    }

    private func claySection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        ClayCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(ClayTheme.text)
                content()
            }
        }
    }

    private func settingsRow(symbol: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(ClayTheme.text)
                .frame(width: 38, height: 38)
                .background(Circle().fill(.white.opacity(0.78)))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(ClayTheme.text)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(ClayTheme.secondaryText)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private func productRow(_ product: Product) -> some View {
        let purchaseState = purchaseManager.purchaseState(for: product.id)

        return HStack(spacing: 12) {
            Image(systemName: product.id == PurchaseManager.lifetimeProductID ? "infinity" : "calendar.badge.clock")
                .font(.headline)
                .foregroundStyle(ClayTheme.text)
                .frame(width: 38, height: 38)
                .background(Circle().fill(.white.opacity(0.78)))

            VStack(alignment: .leading, spacing: 3) {
                Text(product.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(ClayTheme.text)
                Text(product.description)
                    .font(.caption)
                    .foregroundStyle(ClayTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            switch purchaseState {
            case .purchasable:
                ClayButton(product.displayPrice, systemImage: "cart") {
                    Task {
                        await purchaseManager.purchase(product)
                    }
                }
                .disabled(purchaseManager.isLoading)
            case .current, .active, .unavailable:
                Text(statusLabel(for: purchaseState))
                    .font(.caption.bold())
                    .foregroundStyle(ClayTheme.text)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.78))
                    )
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }

    private func statusLabel(for state: PurchaseProductState) -> String {
        switch state {
        case .purchasable:
            ""
        case .current:
            "Current"
        case .active:
            "Active"
        case .unavailable:
            "Unavailable"
        }
    }

    private var membershipSubtitle: String {
        switch purchaseManager.membershipState {
        case .free:
            "Free plan"
        case .annual(let expiresAt):
            if let expiresAt {
                "Annual member until \(expiresAt.formatted(date: .abbreviated, time: .omitted))"
            } else {
                "Annual member"
            }
        case .lifetime:
            "Lifetime member"
        }
    }
}
