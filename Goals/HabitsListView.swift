import SwiftUI

struct HabitsListView: View {
    @Binding var habits: [Habit]
    @State private var showingAddHabitForm : Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(habits.indices, id: \.self) { index in
                    NavigationLink(destination: HabitDetailView(habit: $habits[index])) {
                        VStack(alignment: .leading) {
                            Text(habits[index].title)
                                .font(.headline)
                            HStack {
                                Text("Days Worked: \(habits[index].daysWorked)")
                            }
                            .font(.caption)
                            .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                Button(action: {
                    showingAddHabitForm = true
                }) {
                    Image(systemName: "plus")
                }
            }
            .background(Color(UIColor.systemBackground))
            .sheet(isPresented: $showingAddHabitForm) {
                AddHabitForm(habits: $habits)
            }
        }
    }
}
