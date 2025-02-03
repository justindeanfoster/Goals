import SwiftUI

struct HabitDetailView: View {
    @Binding var habit: Habit
    @State private var showingAddJournalEntryForm = false
    @State private var showingEditHabitForm = false

    var body: some View {
        VStack {
            HStack {
                Text(habit.title)
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: {
                    showingAddJournalEntryForm = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                }
                .sheet(isPresented: $showingAddJournalEntryForm) {
                    AddJournalEntryForm(goal: .constant(nil), habit: .constant(habit))
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading) {
                    // Statistics Section
                    VStack(alignment: .leading) {
                        Text("Statistics")
                            .font(.headline)
                            .padding(.bottom, 5)

                        HStack {
                            Text("Days Worked:")
                            Spacer()
                            Text("\(habit.daysWorked)")
                        }
                        .padding(.bottom, 2)
                    }
                    .padding(.bottom)

                    Divider()

                    if !habit.notes.isEmpty {
                        Text("Notes")
                            .font(.headline)
                        Text(habit.notes)
                            .padding(.bottom, 10)
                    }

                    Text("Milestones")
                        .font(.headline)
                    ForEach(habit.milestones, id: \ .self) { milestone in
                        Text("- \(milestone)")
                    }

                    Divider()

                    Text("Journal Entries")
                        .font(.headline)
                    ForEach(habit.journalEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(" - \(entry.text)")
                            Text(entry.timestamp, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditHabitForm = true
                    }) {
                        Label("Edit Habit", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2) // Smaller font size
                }
            }
        }
        .sheet(isPresented: $showingEditHabitForm) {
            EditHabitForm(habit: $habit)
        }
    }
}
