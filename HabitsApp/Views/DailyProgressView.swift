// File: Views/DailyProgressView.swift
import SwiftUI

struct DailyProgressView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingAddSheet = false
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: Habit?
    @State private var selectedDate: Date? = nil  // Selected bar date
    @State private var selectedCategory = "All"  // For add-sheet filtering
    @State private var selectedType: HabitType? = nil

    /// Builds a continuous date range from first recorded day to today,
    /// mapping each day to its normalized progress (0–1).
    private var progressHistory: [(date: Date, progress: Double)] {
        let pointsDict: [Date: Int] = Dictionary(
            uniqueKeysWithValues: viewModel.dailyHistory.map { entry in
                let day = Calendar.current.startOfDay(for: entry.date)
                let total = entry.habits.reduce(0) { $0 + $1.points }
                return (day, total)
            }
        )
        guard let firstDate = viewModel.dailyHistory.map({ Calendar.current.startOfDay(for: $0.date) }).min() else {
            return []
        }
        let startDate = firstDate
        let endDate = Calendar.current.startOfDay(for: Date())

        var dates: [Date] = []
        var current = startDate
        while current <= endDate {
            dates.append(current)
            guard let next = Calendar.current.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

       return dates.map { date in
           let total = pointsDict[date] ?? 0
            let fraction = min(Double(total) / Double(viewModel.dailyTarget), 1.0)
            return (date: date, progress: fraction)
        }
    }

    /// Maximum pixel height of the bar track
    private let maxBarHeight: CGFloat = 100

    /// Entries to display: filtered by selectedDate if set
    private var displayedHistory: [(date: Date, habits: [Habit])] {
        guard let sel = selectedDate else {
            return viewModel.dailyHistory
        }
        return viewModel.dailyHistory.filter { Calendar.current.isDate($0.date, inSameDayAs: sel) }
    }

    var body: some View {
        VStack {
            // MARK: – Horizontal Progress Chart
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(progressHistory, id: \.date) { entry in
                        VStack(spacing: 4) {
                            // Percentage label
                            Text("\(Int(entry.progress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.primary)

                            ZStack(alignment: .bottom) {
                                // Track background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(entry.progress >= 1.0 ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                                    .frame(width: 20, height: maxBarHeight)
                                // Progress fill
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(entry.progress >= 1.0 ? Color.green : Color.blue)
                                    .frame(width: 20, height: CGFloat(entry.progress) * maxBarHeight)
                            }

                            // Weekday label
                            Text(entry.date, format: .dateTime.weekday(.abbreviated))
                                .font(.caption2)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Toggle selection
                            if let sel = selectedDate,
                               Calendar.current.isDate(sel, inSameDayAs: entry.date) {
                                selectedDate = nil
                            } else {
                                selectedDate = entry.date
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(
                                    Calendar.current.isDate(selectedDate ?? Date.distantPast,
                                                            inSameDayAs: entry.date)
                                    ? Color.accentColor
                                    : Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                }
                .padding(.horizontal)
                .frame(height: maxBarHeight + 40)
            }
            .padding(.vertical)

            // Add activity for selected day
            if selectedDate != nil {
                Button(action: { showingAddSheet = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Activity for Selected Day")
                    }
                    .font(.subheadline.bold())
                    .padding(8)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.bottom)
            }

            // MARK: – Detailed History List
            List {
                ForEach(displayedHistory, id: \.date) { entry in
                    Section(header: Text(entry.date.formatted(date: .abbreviated, time: .omitted))) {
                        let total = entry.habits.reduce(0) { $0 + $1.points }
                        HStack {
                            Text("Total Points:")
                            Spacer()
                            Text("\(total)")
                                .bold()
                                .foregroundColor(total >= 0 ? .green : .red)
                        }

                        ForEach(entry.habits, id: \.id) { habit in
                            ActivityRow(habit: habit, date: viewModel.completionDate(for: habit)) {
                                habitToDelete = habit
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Daily Progress")
        }
        // MARK: – Add-sheet
        .sheet(isPresented: $showingAddSheet) {
            HabitSelectionView(
                selectedCategory: $selectedCategory,
                selectedType: $selectedType,
                completionDate: selectedDate
            )
            .environmentObject(viewModel)
        }
        // MARK: – Delete Alert
        .alert("Remove Activity", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                if let habit = habitToDelete {
                    viewModel.remove(habit)
                }
            }
        } message: {
            Text("Are you sure you want to remove this activity?")
        }
    }
}
