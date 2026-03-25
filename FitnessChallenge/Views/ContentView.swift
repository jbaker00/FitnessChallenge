import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChallengeViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "bolt.fill")
                }
                .tag(0)

            TodayView()
                .tabItem {
                    Label("Today", systemImage: "flame.fill")
                }
                .tag(1)

            AllDaysView()
                .tabItem {
                    Label("All Days", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Me", systemImage: "person.fill")
                }
                .tag(3)
        }
        .environmentObject(viewModel)
        .tint(.electricBlue)
        .onAppear {
            // Style the tab bar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.charcoal)

            // Normal item color
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.dimmedText)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(Color.dimmedText)
            ]

            // Selected item color
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.electricBlue)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.electricBlue)
            ]

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
