import SwiftUI
import CoreData

struct UnitDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var unit: UnitEntity
    @State private var showingAddAssignment = false
    @State private var showingEditUnit = false

    private let calculator = ProgressCalculator()

    var body: some View {
        List {
            Section("Progress") {
                let breakdown = calculator.unitProgress(unit)
                ProgressView(value: breakdown.overallPercentage / 100)
                Text("\(Int(breakdown.overallPercentage))% across \(Int(breakdown.totalWeight)) weighting")
            }

            Section("Assignments") {
                ForEach(unit.assignmentsArray) { assignment in
                    NavigationLink(destination: AssignmentDetailView(assignment: assignment)) {
                        AssignmentRowView(assignment: assignment, scheduler: ReminderScheduler(center: UNUserNotificationCenter.current()))
                    }
                }
                .onDelete(perform: deleteAssignment)
            }
        }
        .navigationTitle(unit.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: { showingAddAssignment = true }) {
                    Label("Add", systemImage: "plus")
                }
                Button("Edit") { showingEditUnit = true }
            }
        }
        .sheet(isPresented: $showingAddAssignment) {
            AssignmentFormView(unit: unit)
        }
        .sheet(isPresented: $showingEditUnit) {
            UnitFormView(unit: unit)
        }
    }

    private func deleteAssignment(at offsets: IndexSet) {
        offsets.map { unit.assignmentsArray[$0] }.forEach(context.delete)
        try? context.save()
    }
}
