import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: UnitEntity.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \UnitEntity.name, ascending: true)])
    private var units: FetchedResults<UnitEntity>
    @EnvironmentObject private var preferences: UserPreferences

    private let calculator = ProgressCalculator()
    private let reminderScheduler = ReminderScheduler(center: UNUserNotificationCenter.current())

    @State private var searchText = ""
    @State private var sortOption: UnitSortOption = .name

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                progressHeader
                upcomingList
                UnitListView(units: filteredUnits, sortOption: sortOption)
            }
            .padding()
            .navigationTitle("Dashboard")
            .searchable(text: $searchText)
            .toolbar {
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(UnitSortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }

    private var progressHeader: some View {
        let overall = calculator.overallProgress(units: Array(units))
        return VStack(alignment: .leading, spacing: 8) {
            Text("Overall Progress")
                .font(.headline)
            ProgressView(value: overall / 100)
            Text("\(Int(overall))% complete")
                .font(.subheadline)
        }
    }

    private var filteredUnits: [UnitEntity] {
        units.filter { unit in
            searchText.isEmpty || unit.name.localizedCaseInsensitiveContains(searchText) || unit.code.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var upcomingList: some View {
        let assignments = units.flatMap { $0.assignmentsArray }
        let filtered = assignments.filter { assignment in
            let risk = calculator.riskLevel(for: assignment)
            if preferences.showAtRiskOnly {
                return risk != .none
            }
            return true
        }
        let sorted = filtered.sorted { $0.dueDate < $1.dueDate }.prefix(3)
        return VStack(alignment: .leading) {
            HStack {
                Text("Upcoming Deadlines")
                    .font(.headline)
                Spacer()
                Toggle("At-risk only", isOn: $preferences.showAtRiskOnly)
                    .labelsHidden()
            }
            ForEach(sorted, id: \\.id) { assignment in
                AssignmentRowView(assignment: assignment, scheduler: reminderScheduler)
            }
        }
    }
}

struct AssignmentRowView: View {
    let assignment: AssignmentEntity
    let scheduler: ReminderScheduler
    private let calculator = ProgressCalculator()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(assignment.title)
                Spacer()
                Text(assignment.dueDate, style: .date)
            }
            ProgressView(value: calculator.assignmentProgress(assignment) / 100)
            HStack {
                Text(assignment.statusValue.rawValue.capitalized)
                    .font(.caption)
                Spacer()
                Button("Remind") {
                    scheduler.scheduleReminder(for: assignment, leadHours: 24)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.secondarySystemBackground)))
    }
}

enum UnitSortOption: String, CaseIterable, Identifiable {
    case name, dueDate, progress
    var id: String { rawValue }
    var title: String {
        switch self {
        case .name: return "Name"
        case .dueDate: return "Nearest Due"
        case .progress: return "Progress"
        }
    }
}
