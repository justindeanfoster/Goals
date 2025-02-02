//
//  AddGoalForm.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI



struct AddGoalForm: View {
    @Binding var goals: [Goal]
    @Binding var availableHabits: [Habit]  // This should be passed or fetched from a data source

    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var deadline: Date = Date()
    @State private var milestones: [String] = []
    @State private var newMilestone: String = ""
    @State private var notes: String = "" // New state for notes
    @State private var selectedHabits: [Habit] = []
    @State private var showValidationError: Bool = false // State for validation error

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Goal Title", text: $title)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Text("Notes:")
                    TextEditor(text: $notes) // Notes input
                        .frame(minHeight: 100)
                        .border(Color.gray, width: 1)
                        .padding(.top, 5)
                }

                Section(header: Text("Milestones")) {
                    ForEach(milestones, id: \ .self) { milestone in
                        Text(milestone)
                    }
                    HStack {
                        TextField("New Milestone", text: $newMilestone)
                        Button(action: {
                            if !newMilestone.isEmpty {
                                milestones.append(newMilestone)
                                newMilestone = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }

                Section(header: Text("Related Habits")) {
                    ForEach(availableHabits) { habit in
                        HStack {
                            Text(habit.title)
                            Spacer()
                            if selectedHabits.contains(where: { $0.id == habit.id }) {
                                Button(action: {
                                    if let index = selectedHabits.firstIndex(where: { $0.id == habit.id }) {
                                        selectedHabits.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                            } else {
                                Button(action: {
                                    selectedHabits.append(habit)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showValidationError) {
                Alert(title: Text("Validation Error"),
                      message: Text("Please provide a title."),
                      dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Add New Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if title.isEmpty {
                            showValidationError = true
                        } else {
                            let newGoal = Goal(title: title, deadline: deadline, milestones: milestones, notes: notes, relatedHabits: selectedHabits)
                            goals.append(newGoal)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
