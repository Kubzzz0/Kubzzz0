import SwiftUI

struct AssignmentFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    var unit: UnitEntity?

    @State private var title: String = ""
    @State private var weighting: Double = 10
    @State private var dueDate: Date = .now
    @State private var status: AssignmentStatus = .notStarted
    @State private var submissionLink: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                Stepper(value: $weighting, in: 0...100, step: 5) {
                    Text("Weighting: \(Int(weighting))%")
                }
                DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                Picker("Status", selection: $status) {
                    ForEach(AssignmentStatus.allCases) { status in
                        Text(status.rawValue.capitalized).tag(status)
                    }
                }
                TextField("Submission Link", text: $submissionLink)
                    .keyboardType(.URL)
            }
            .navigationTitle("Add Assignment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { dismiss() })
                }
            }
        }
    }

    private func save() {
        guard let unit else { return }
        let assignment = AssignmentEntity(context: context)
        assignment.id = UUID()
        assignment.title = title
        assignment.weighting = weighting
        assignment.dueDate = dueDate
        assignment.status = status.rawValue
        if !submissionLink.isEmpty { assignment.submissionLink = submissionLink }
        assignment.unit = unit
        try? context.save()
        dismiss()
    }
}
