// File: Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: HabitViewModel
    @State private var showingHabitList = false
    @State private var selectedCategory = "All"
    @State private var selectedType: HabitType? = nil

    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // No more arguments—ProfileHeader reads name/points from viewModel
                        ProfileHeader()

                        ProgressRing(progress: viewModel.dailyProgress)
                            .frame(width: 150, height: 150)
                            .padding(.vertical)

                        Button(action: { showingHabitList = true }) {
                            Label("Add Progress", systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(ModernButtonStyle())
                        .padding(.horizontal)

                        NavigationLink(destination:
                            DailyProgressView()
                                .environmentObject(viewModel)
                        ) {
                            Label("Daily", systemImage: "calendar")
                                .font(.headline)
                        }
                        .buttonStyle(ModernButtonStyle())
                        .padding(.horizontal)

                        RecentActivityView()
                    }
                    .padding()
                }
                .navigationTitle("")
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingHabitList) {
                    HabitSelectionView(
                        selectedCategory: $selectedCategory,
                        selectedType:   $selectedType
                    )
                    .environmentObject(viewModel)
                }
            }

            // Undo toast banner
            if viewModel.lastDeletion != nil {
                VStack {
                    Spacer()
                    HStack {
                        Text("Activity removed")
                        Spacer()
                        Button("Undo") {
                            viewModel.undoLastDeletion()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: viewModel.lastDeletion != nil)
    }
}
