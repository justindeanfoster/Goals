//
//  AddGoalForm.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI



struct AddHabitForm: View {
    @Binding var habits: [Habit]
    @Environment(\.presentationMode) var presentationMode

    @State private var title: String = ""
    @State private var milestones: [String] = []
    @State private var newMilestone: String = ""
    @State private var notes: String = "" // New state for notes
    @State private var showValidationError: Bool = false // State for validation error

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Habit Title", text: $title)
                    Text("Notes:")
                    TextEditor(text: $notes) // Notes input
                        .frame(minHeight: 100)
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
            }
            .alert(isPresented: $showValidationError) {
                Alert(title: Text("Validation Error"),
                      message: Text("Please provide a title."),
                      dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Add New Habit")
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
                            let newHabit = Habit(title: title, milestones: milestones, notes: notes)
                            habits.append(newHabit)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
