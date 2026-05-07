import Foundation
import Combine
import UserNotifications
import EventKit

final class UserPreferences: ObservableObject {
    @Published var notificationLeadTimeHours: Int {
        didSet { UserDefaults.standard.set(notificationLeadTimeHours, forKey: Self.leadKey) }
    }
    @Published var showAtRiskOnly: Bool {
        didSet { UserDefaults.standard.set(showAtRiskOnly, forKey: Self.atRiskKey) }
    }

    private static let leadKey = "notificationLeadTimeHours"
    private static let atRiskKey = "showAtRiskOnly"

    init() {
        let storedLead = UserDefaults.standard.integer(forKey: Self.leadKey)
        notificationLeadTimeHours = storedLead == 0 ? 24 : storedLead
        showAtRiskOnly = UserDefaults.standard.bool(forKey: Self.atRiskKey)
    }
}

struct ReminderScheduler {
    let center: UNUserNotificationCenter

    func scheduleReminder(for assignment: AssignmentEntity, leadHours: Int) {
        guard let title = assignment.title as String?, leadHours > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Upcoming: \(title)"
        content.body = "Due \(formatted(date: assignment.dueDate))."
        content.sound = .default

        let triggerDate = Calendar.current.date(byAdding: .hour, value: -leadHours, to: assignment.dueDate) ?? assignment.dueDate
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(triggerDate.timeIntervalSinceNow, 5), repeats: false)
        let request = UNNotificationRequest(identifier: assignment.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder(for assignment: AssignmentEntity) {
        center.removePendingNotificationRequests(withIdentifiers: [assignment.id.uuidString])
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct CalendarExporter {
    let eventStore: EKEventStore

    func addAssignmentEvent(_ assignment: AssignmentEntity, to calendar: EKCalendar? = nil) throws {
        guard let title = assignment.title as String? else { return }
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = assignment.dueDate
        event.endDate = assignment.dueDate.addingTimeInterval(60 * 60)
        event.calendar = calendar ?? eventStore.defaultCalendarForNewEvents
        try eventStore.save(event, span: .thisEvent)
    }
}
