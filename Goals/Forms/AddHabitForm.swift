//
//  AddGoalForm.swift
//  Goals
//
//  Created by Justin F on 1/25/25.
//

import SwiftUI
import SwiftData

struct AddHabitForm: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var milestones: [String] = []
    @State private var newMilestone: String = ""
    @State private var notes: String = ""
    @State private var showValidationError: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Habit Title", text: $title)
                    Text("Notes:")
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                        if notes.isEmpty {
                            Text("Write about your progress...")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                    }
                }

            }
            .alert(isPresented: $showValidationError) {
                Alert(title: Text("Validation Error"),
                      message: Text("Please provide a title."),
                      dismissButton: .default(Text("OK")))
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
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
                            do {
                                let newHabit = Habit(title: title, milestones: milestones, notes: notes)
                                modelContext.insert(newHabit)
                                try modelContext.save()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                errorMessage = "Failed to save: \(error.localizedDescription)"
                                showError = true
                                print("Save error: \(error)")
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}
