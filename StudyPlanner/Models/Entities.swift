import Foundation
import CoreData

@objc(UnitEntity)
public class UnitEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var code: String
    @NSManaged public var assignments: NSSet?
}

extension UnitEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitEntity> {
        NSFetchRequest<UnitEntity>(entityName: "UnitEntity")
    }

    var assignmentsArray: [AssignmentEntity] {
        (assignments as? Set<AssignmentEntity> ?? []).sorted { $0.dueDate < $1.dueDate }
    }
}

@objc(AssignmentEntity)
public class AssignmentEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var weighting: Double
    @NSManaged public var dueDate: Date
    @NSManaged public var status: String?
    @NSManaged public var grade: GradeEntity?
    @NSManaged public var submissionLink: String?
    @NSManaged public var unit: UnitEntity?
}

extension AssignmentEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssignmentEntity> {
        NSFetchRequest<AssignmentEntity>(entityName: "AssignmentEntity")
    }
}

@objc(GradeEntity)
public class GradeEntity: NSManagedObject {
    @NSManaged public var score: Double
    @NSManaged public var maxScore: Double
    @NSManaged public var assignment: AssignmentEntity?
}
