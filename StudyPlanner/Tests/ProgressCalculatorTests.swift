import XCTest
@testable import StudyPlanner

final class ProgressCalculatorTests: XCTestCase {
    func testUnitProgressWeightedAverage() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let unit = UnitEntity(context: context)
        unit.id = UUID()
        unit.name = "Math"
        unit.code = "MTH101"

        let a1 = AssignmentEntity(context: context)
        a1.id = UUID(); a1.title = "Quiz"; a1.weighting = 40; a1.dueDate = Date()
        let g1 = GradeEntity(context: context); g1.score = 18; g1.maxScore = 20; a1.grade = g1

        let a2 = AssignmentEntity(context: context)
        a2.id = UUID(); a2.title = "Project"; a2.weighting = 60; a2.dueDate = Date()
        let g2 = GradeEntity(context: context); g2.score = 45; g2.maxScore = 50; a2.grade = g2

        unit.assignments = NSSet(array: [a1, a2])

        let calculator = ProgressCalculator()
        let breakdown = calculator.unitProgress(unit)
        XCTAssertEqual(Int(breakdown.overallPercentage.rounded()), 90)
    }

    func testRiskDetection() {
        let context = PersistenceController(inMemory: true).container.viewContext
        let assignment = AssignmentEntity(context: context)
        assignment.id = UUID(); assignment.title = "Essay"; assignment.weighting = 20
        assignment.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
        assignment.status = AssignmentStatus.inProgress.rawValue

        let calculator = ProgressCalculator()
        XCTAssertEqual(calculator.riskLevel(for: assignment), .dueSoon)
    }
}
