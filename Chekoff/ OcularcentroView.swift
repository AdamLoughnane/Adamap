import SwiftUI

struct OcularcentroView: View {
    @State private var checks: [Bool] = Array(repeating: false, count: 5)
    @State private var remindersOn: Bool = UserDefaults.standard.bool(forKey: "ocularcentroRemindersOn")
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Ocularcentro")
                .font(.largeTitle)
                .padding(.top, 40)
            
            // The 5 buttons
            HStack(spacing: 10) {
                ForEach(0..<checks.count, id: \.self) { i in
                    Button {
                        checks[i].toggle()
                        saveChecks()
                    } label: {
                        CheckDot(isOn: $checks[i])
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Toggle for buzz reminders
            Toggle(isOn: $remindersOn) {
                Text("Half-hour buzz (10–4)")
                    .font(.headline)
            }
            .toggleStyle(SwitchToggleStyle(tint: .teal))
            .padding(.horizontal)
            .onChange(of: remindersOn) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "ocularcentroRemindersOn")
                if newValue {
                    NotificationManager.shared.scheduleHalfHourReminders()
                } else {
                    NotificationManager.shared.cancelReminders()
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadChecks()
            scheduleMidnightReset()
            if remindersOn {
                NotificationManager.shared.scheduleHalfHourReminders()
            }
           // NotificationManager.shared.scheduleTestNotification()

        }
    }
    
    // MARK: - Persistence
    private func saveChecks() {
        UserDefaults.standard.set(checks, forKey: "ocularcentroChecks")
    }
    
    private func loadChecks() {
        if let saved = UserDefaults.standard.array(forKey: "ocularcentroChecks") as? [Bool] {
            checks = saved
        }
    }
    
    // MARK: - Midnight reset
    private func scheduleMidnightReset() {
        let now = Date()
        var tomorrow = Calendar.current.startOfDay(for: now)
        tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
        
        let interval = tomorrow.timeIntervalSince(now)
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            checks = Array(repeating: false, count: 5)
            saveChecks()
            scheduleMidnightReset() // schedule again for the next night
        }
    }
}
