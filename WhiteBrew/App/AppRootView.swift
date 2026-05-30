import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: AppTab = .today
    @State private var purchaseManager = PurchaseManager()

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem { Label(AppTab.today.title, systemImage: AppTab.today.symbol) }
                .tag(AppTab.today)

            RecordsView()
                .tabItem { Label(AppTab.records.title, systemImage: AppTab.records.symbol) }
                .tag(AppTab.records)

            StatsView()
                .tabItem { Label(AppTab.stats.title, systemImage: AppTab.stats.symbol) }
                .tag(AppTab.stats)

            CabinetView()
                .tabItem { Label(AppTab.cabinet.title, systemImage: AppTab.cabinet.symbol) }
                .tag(AppTab.cabinet)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.symbol) }
                .tag(AppTab.profile)
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
