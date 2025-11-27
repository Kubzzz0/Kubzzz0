import Foundation
import CoreData

enum AssignmentStatus: String, CaseIterable, Identifiable, Codable {
    case notStarted, inProgress, submitted, completed
    var id: String { rawValue }
}

struct AssignmentModel: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var weighting: Double
    var dueDate: Date
    var status: AssignmentStatus
    var grade: GradeModel?
    var submissionLink: URL?
}

struct UnitModel: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var code: String
    var assignments: [AssignmentModel]
}

struct GradeModel: Codable {
    var score: Double
    var maxScore: Double

    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore) * 100
    }
}

extension UnitEntity {
    func update(from model: UnitModel, context: NSManagedObjectContext) {
        id = model.id
        name = model.name
        code = model.code
        assignments = NSSet(array: model.assignments.map { assignment in
            let entity = AssignmentEntity(context: context)
            entity.update(from: assignment)
            return entity
        })
    }
}

extension AssignmentEntity {
    func update(from model: AssignmentModel) {
        id = model.id
        title = model.title
        weighting = model.weighting
        dueDate = model.dueDate
        status = model.status.rawValue
        if let gradeModel = model.grade {
            let gradeEntity = GradeEntity(context: managedObjectContext!)
            gradeEntity.score = gradeModel.score
            gradeEntity.maxScore = gradeModel.maxScore
            grade = gradeEntity
        }
        if let link = model.submissionLink {
            submissionLink = link.absoluteString
        }
    }

    var statusValue: AssignmentStatus {
        AssignmentStatus(rawValue: status ?? "notStarted") ?? .notStarted
    }
}

extension GradeEntity {
    var percentage: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore) * 100
    }
}
