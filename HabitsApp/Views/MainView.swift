import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: HabitViewModel

    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Today",     systemImage: "house.fill") }

            InsightsView()
                .tabItem { Label("Insights",  systemImage: "chart.bar.fill") }

            AchievementsView()
                .tabItem { Label("Trophies",  systemImage: "trophy.fill") }
        }
        .environmentObject(viewModel)
    }
}
