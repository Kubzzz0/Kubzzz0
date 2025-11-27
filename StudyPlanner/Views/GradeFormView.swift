import SwiftUI

struct GradeFormView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var assignment: AssignmentEntity

    @State private var score: Double = 0
    @State private var maxScore: Double = 100

    var body: some View {
        Form {
            Stepper(value: $score, in: 0...maxScore, step: 1) {
                Text("Score: \(score, specifier: "%.0f")")
            }
            Stepper(value: $maxScore, in: 1...200, step: 1) {
                Text("Max Score: \(maxScore, specifier: "%.0f")")
            }
            Button("Save Grade", action: save)
        }
        .navigationTitle("Grade")
        .onAppear {
            if let grade = assignment.grade {
                score = grade.score
                maxScore = grade.maxScore
            }
        }
    }

    private func save() {
        let grade = assignment.grade ?? GradeEntity(context: context)
        grade.score = score
        grade.maxScore = maxScore
        assignment.grade = grade
        assignment.status = AssignmentStatus.completed.rawValue
        try? context.save()
        dismiss()
    }
}
