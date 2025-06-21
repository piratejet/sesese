import SwiftUI

struct MainView: View {
    @EnvironmentObject private var viewModel: HabitViewModel

    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Home",      systemImage: "house.fill") }

            DailyProgressView()
                .tabItem { Label("Daily",     systemImage: "calendar") }

            InsightsView()
                .tabItem { Label("Insights",  systemImage: "chart.bar.fill") }

            AchievementsView()
                .tabItem { Label("Trophies",  systemImage: "trophy.fill") }

            HabitTemplatesView()
                .tabItem { Label("Habits", systemImage: "list.bullet") }
        }
        .environmentObject(viewModel)
    }
}
