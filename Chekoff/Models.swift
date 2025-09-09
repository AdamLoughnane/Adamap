import SwiftUI

// MARK: - Timer Manager
class TimerManager: ObservableObject {
    @Published var activities: [Activity]
    private var timers: [UUID: Timer] = [:]
    
    init(activities: [Activity]) {
        self.activities = activities
    }
    
    func startTimer(for activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index].timeRemaining = 600        // 10 minutes
        activities[index].isPaused = false
        
        timers[activity.id]?.invalidate()
        timers[activity.id] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { return }
            guard let i = self.activities.firstIndex(where: { $0.id == activity.id }) else {
                t.invalidate(); return
            }
            if let remaining = self.activities[i].timeRemaining,
               remaining > 0,
               !self.activities[i].isPaused {
                self.activities[i].timeRemaining = remaining - 1
            } else {
                t.invalidate()
                self.activities[i].timeRemaining = nil
            }
        }
    }
    
    func pauseTimer(for activity: Activity) {
        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }
        activities[index].isPaused.toggle()
    }
    
    func cancelTimer(for activity: Activity) {
        timers[activity.id]?.invalidate()
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index].timeRemaining = nil
            activities[index].isPaused = false
        }
    }
    
    func cancelAllTimers() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
    }
}

// MARK: - Data Model
struct Activity: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var checks: [Bool]
    var timeRemaining: Int? = nil   // seconds left; nil = no active timer
    var isPaused: Bool = false
    
    // Compare by id only (prevents crashes when other fields change).
    static func == (lhs: Activity, rhs: Activity) -> Bool { lhs.id == rhs.id }
}

// MARK: - App Settings
let activitiesCount = 8
let checksPerActivity = 5

func makeInitialActivities() -> [Activity] {
    (0..<activitiesCount).map { _ in
        Activity(name: "", checks: Array(repeating: false, count: checksPerActivity))
    }
}

// MARK: - Colors
extension Color {
    static let checklistGreen = Color(red: 151/255, green: 198/255, blue: 6/255)
    static let resetRed = Color(red: 217/255, green: 121/255, blue: 121/255)
}

// MARK: - Persistence
enum Storage {
    static let key = "activities.v1"
    
    static func load() -> [Activity] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([Activity].self, from: data)
        else { return makeInitialActivities() }
        
        // Migrate if button count changes
        return decoded.map { old in
            var a = old
            if a.checks.count != checksPerActivity {
                a.checks = Array(a.checks.prefix(checksPerActivity))
                if a.checks.count < checksPerActivity {
                    a.checks.append(contentsOf: Array(repeating: false, count: checksPerActivity - a.checks.count))
                }
            }
            return a
        }
    }
    
    static func save(_ activities: [Activity]) {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
