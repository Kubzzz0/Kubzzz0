import SwiftUI
import UserNotifications
import EventKit

struct AssignmentDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var assignment: AssignmentEntity
    @State private var showingEdit = false

    private let calculator = ProgressCalculator()
    private let reminderScheduler = ReminderScheduler(center: UNUserNotificationCenter.current())
    private let exporter = CalendarExporter(eventStore: EKEventStore())

    var body: some View {
        Form {
            Section("Status") {
                Picker("Status", selection: Binding(
                    get: { assignment.statusValue },
                    set: { assignment.status = $0.rawValue; save() }
                )) {
                    ForEach(AssignmentStatus.allCases) { status in
                        Text(status.rawValue.capitalized).tag(status)
                    }
                }
                DatePicker("Due Date", selection: Binding(get: { assignment.dueDate }, set: { assignment.dueDate = $0; save() }), displayedComponents: [.date, .hourAndMinute])
            }

            Section("Grade") {
                if let grade = assignment.grade {
                    Text("Score: \(grade.score)/\(grade.maxScore)")
                    ProgressView(value: grade.percentage / 100)
                }
                NavigationLink("Enter Grade") {
                    GradeFormView(assignment: assignment)
                }
            }

            Section("Links") {
                if let link = assignment.submissionLink, let url = URL(string: link) {
                    Link("Submission", destination: url)
                }
                Button("Set Reminder") {
                    reminderScheduler.scheduleReminder(for: assignment, leadHours: 24)
                }
                Button("Export to Calendar") {
                    EKEventStore().requestAccess(to: .event) { granted, _ in
                        if granted { try? exporter.addAssignmentEvent(assignment) }
                    }
                }
            }
        }
        .navigationTitle(assignment.title)
        .toolbar {
            Button("Edit") { showingEdit = true }
        }
        .sheet(isPresented: $showingEdit) {
            AssignmentFormView(unit: assignment.unit)
        }
    }

    private func save() {
        try? context.save()
    }
}
