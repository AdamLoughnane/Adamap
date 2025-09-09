import SwiftUI

// MARK: - Main checklist screen
struct ChecklistView: View {
    @StateObject private var timerManager = TimerManager(activities: Storage.load())
    @State private var showRestartConfirm = false
    @State private var selectedActivity: Activity? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(timerManager.activities.indices, id: \.self) { i in
                    ActivityRow(
                        activity: $timerManager.activities[i],
                        placeholder: "Activity \(i + 1)"
                    ) { tapped in
                        timerManager.startTimer(for: tapped)
                        selectedActivity = tapped
                    }
                }
                
                Divider().padding(.top, 6)
                
                HStack(spacing: 12) {
                    Button(role: .destructive) { resetChecks() } label: {
                        Label("Reset checks", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.checklistGreen)
                    
                    Button(role: .destructive) { showRestartConfirm = true } label: {
                        Label("Restart", systemImage: "trash")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.resetRed)
                }
                .padding(.top, 2)
            }
            .padding()
        }
        .navigationTitle("Weekly Checklist")
        .alert("Restart everything?", isPresented: $showRestartConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Restart", role: .destructive) { restartAll() }
        } message: {
            Text("This clears all activity names and unchecks all buttons.")
        }
        .sheet(item: $selectedActivity) { activity in
            TimerSheet(activity: binding(for: activity), timerManager: timerManager)
        }
        .onChange(of: timerManager.activities) { _, newValue in
            Storage.save(newValue)
        }
    }
    
    // MARK: - Actions
    private func resetChecks() {
        for i in timerManager.activities.indices {
            timerManager.activities[i].checks = Array(repeating: false, count: checksPerActivity)
        }
        Storage.save(timerManager.activities)
    }
    
    private func restartAll() {
        timerManager.cancelAllTimers()
        timerManager.activities = makeInitialActivities()
        Storage.save(timerManager.activities)
    }
    
    private func binding(for activity: Activity) -> Binding<Activity> {
        guard let index = timerManager.activities.firstIndex(where: { $0.id == activity.id }) else {
            fatalError("Activity not found")
        }
        return $timerManager.activities[index]
    }
}

// MARK: - Round dot
struct CheckDot: View {
    @Binding var isOn: Bool
    var body: some View {
        Circle()
            .fill(isOn ? Color.checklistGreen : Color(.systemGray5))
            .frame(width: 28, height: 28)
            .overlay(Circle().stroke(Color.secondary, lineWidth: 1))
            .contentShape(Circle())
    }
}

// MARK: - Activity row
struct ActivityRow: View {
    @Binding var activity: Activity
    let placeholder: String
    let onStartTimer: (Activity) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(placeholder, text: $activity.name, prompt: Text(placeholder))
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .frame(minWidth: 140)
            
            Spacer(minLength: 8)
            
            HStack(spacing: 10) {
                ForEach(0..<checksPerActivity, id: \.self) { j in
                    Button {
                        activity.checks[j].toggle()
                        onStartTimer(activity)
                    } label: {
                        CheckDot(isOn: $activity.checks[j])
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(activity.checks[j] ? "Marked" : "Unmarked")
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Timer sheet
struct TimerSheet: View {
    @Binding var activity: Activity
    let timerManager: TimerManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(activity.name.isEmpty ? "Timer" : activity.name)
                .font(.title2).bold()
            
            if let remaining = activity.timeRemaining {
                Text(formatTime(remaining))
                    .font(.system(size: 48, weight: .medium, design: .monospaced))
            } else {
                Text("No active timer")
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                Button(activity.isPaused ? "Resume" : "Pause") {
                    timerManager.pauseTimer(for: activity)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Cancel") {
                    timerManager.cancelTimer(for: activity)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
        .presentationDetents([.fraction(0.35), .medium])
    }
}

// MARK: - Helper
func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let secs = seconds % 60
    return String(format: "%02d:%02d", minutes, secs)
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ChecklistView()
    }
}
