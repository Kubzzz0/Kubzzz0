import Foundation

struct ProgressBreakdown {
    let completedWeight: Double
    let totalWeight: Double
    let overallPercentage: Double
}

enum AtRiskLevel { case none, dueSoon, overdue }

struct ProgressCalculator {
    func assignmentProgress(_ assignment: AssignmentEntity) -> Double {
        guard let grade = assignment.grade else { return 0 }
        return grade.percentage
    }

    func unitProgress(_ unit: UnitEntity) -> ProgressBreakdown {
        let assignments = unit.assignmentsArray
        let totalWeight = assignments.reduce(0) { $0 + $1.weighting }
        let weightedScore = assignments.reduce(0) { partial, assignment in
            let score = assignment.grade?.percentage ?? 0
            return partial + (score * assignment.weighting)
        }
        let overall = totalWeight > 0 ? weightedScore / totalWeight : 0
        let completed = assignments.filter { $0.statusValue == .completed || $0.statusValue == .submitted }
            .reduce(0) { $0 + $1.weighting }
        return ProgressBreakdown(completedWeight: completed, totalWeight: totalWeight, overallPercentage: overall)
    }

    func overallProgress(units: [UnitEntity]) -> Double {
        let breakdowns = units.map(unitProgress)
        let totalWeight = breakdowns.reduce(0) { $0 + $1.totalWeight }
        let weightedScore = breakdowns.reduce(0) { $0 + ($1.overallPercentage * $1.totalWeight) }
        return totalWeight > 0 ? weightedScore / totalWeight : 0
    }

    func riskLevel(for assignment: AssignmentEntity, now: Date = .now) -> AtRiskLevel {
        let calendar = Calendar.current
        guard let due = assignment.dueDate as Date? else { return .none }
        if due < now { return .overdue }
        let days = calendar.dateComponents([.day], from: now, to: due).day ?? 0
        return days <= 3 && assignment.statusValue != .completed ? .dueSoon : .none
    }
}
