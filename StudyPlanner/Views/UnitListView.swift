import SwiftUI

struct UnitListView: View {
    let units: [UnitEntity]
    let sortOption: UnitSortOption
    private let calculator = ProgressCalculator()

    var body: some View {
        List(sortedUnits) { unit in
            NavigationLink(destination: UnitDetailView(unit: unit)) {
                VStack(alignment: .leading) {
                    Text(unit.name)
                    Text(unit.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ProgressView(value: calculator.unitProgress(unit).overallPercentage / 100)
                }
            }
        }
    }

    private var sortedUnits: [UnitEntity] {
        switch sortOption {
        case .name:
            return units.sorted { $0.name < $1.name }
        case .dueDate:
            return units.sorted { ($0.assignmentsArray.first?.dueDate ?? .distantFuture) < ($1.assignmentsArray.first?.dueDate ?? .distantFuture) }
        case .progress:
            return units.sorted { calculator.unitProgress($0).overallPercentage > calculator.unitProgress($1).overallPercentage }
        }
    }
}
