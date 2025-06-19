// File: Views/AchievementsView.swift
import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var viewModel: HabitViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.achievements) { achievement in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: achievement.unlockedDate != nil ? "trophy.fill" : "lock.fill")
                        .foregroundColor(achievement.unlockedDate != nil ? .yellow : .gray)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(achievement.title)
                            .font(.headline)
                        Text(achievement.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let date = achievement.unlockedDate {
                            Text("Unlocked " + date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Achievements")
        }
    }
}
