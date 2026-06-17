import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: AppTab = .today
    @State private var purchaseManager = PurchaseManager()

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(AppTab.today)

                RecordsView()
                    .tag(AppTab.records)

                StatsView()
                    .tag(AppTab.stats)

                CabinetView()
                    .tag(AppTab.cabinet)

                ProfileView()
                    .tag(AppTab.profile)
            }
            .toolbar(.hidden, for: .tabBar)

            FloatingCoffeeTabBar(selectedTab: $selectedTab)
        }
        .environment(purchaseManager)
        .task {
            purchaseManager.startObservingTransactions()
            await purchaseManager.refreshEntitlements()
            await purchaseManager.loadProducts()
        }
        .onDisappear {
            purchaseManager.stopObservingTransactions()
        }
    }
}

private struct FloatingCoffeeTabBar: View {
    @Binding var selectedTab: AppTab

    private let visibleTabs: [AppTab] = [.stats, .today, .records]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(visibleTabs) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Image(systemName: tab.symbol)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedTab == tab ? ClayTheme.accentSage : ClayTheme.text)
                        .frame(width: 62, height: 44)
                        .background {
                            if selectedTab == tab {
                                Capsule(style: .continuous)
                                    .fill(ClayTheme.surface)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.white.opacity(0.92), in: Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(ClayTheme.hairline.opacity(0.7), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.10), radius: 18, x: 0, y: 10)
        .padding(.bottom, 18)
    }
}
