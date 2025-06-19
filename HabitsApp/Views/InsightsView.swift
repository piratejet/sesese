// File: Views/InsightsView.swift
import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject private var viewModel: HabitViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Chart(viewModel.pointsLast30Days, id: \.date) { item in
                    LineMark(
                        x: .value("Date",  item.date),
                        y: .value("Points", item.points)
                    )
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 200)
                .chartXAxis { AxisMarks(values: .stride(by: .day, count: 7)) }

                Chart(viewModel.rolling7DayAverage, id: \.date) { item in
                    AreaMark(
                        x: .value("Date", item.date),
                        y: .value("Avg",  item.average)
                    )
                }
                .frame(height: 150)

                Chart(viewModel.monthlyTotals, id: \.month) { item in
                    BarMark(
                        x: .value("Month", item.month, unit: .month),
                        y: .value("Points", item.points)
                    )
                }
                .frame(height: 180)
                .chartXAxis { AxisMarks(values: .stride(by: .month, count: 1)) }

                VStack(alignment: .leading, spacing: 8) {
                    if let best = viewModel.bestDay {
                        HStack {
                            Text("Best Day:")
                            Spacer()
                            Text(best.date, format: .dateTime.month().day()) + Text(" +\(best.points) pts")
                        }
                    }
                    if let worst = viewModel.worstDay {
                        HStack {
                            Text("Worst Day:")
                            Spacer()
                            Text(worst.date, format: .dateTime.month().day()) + Text(" \(worst.points) pts")
                        }
                    }
                    HStack {
                        Text("Avg/Day:")
                        Spacer()
                        Text(String(format: "%.1f", viewModel.averagePointsPerDay))
                    }
                    HStack {
                        Text("Streak:")
                        Spacer()
                        Text("\(viewModel.currentStreak) days")
                    }
                }
                .padding(.horizontal)

                Chart(viewModel.weeklyCompletionCounts, id: \.weekStart) { item in
                    BarMark(
                        x: .value("Week", item.weekStart, unit: .weekOfYear),
                        y: .value("Count", item.count)
                    )
                }
                .frame(height: 150)
                .chartXAxis { AxisMarks(values: .stride(by: .weekOfYear, count: 1)) }
            }
            .padding()
        }
        .navigationTitle("Insights & Trends")
    }
}
