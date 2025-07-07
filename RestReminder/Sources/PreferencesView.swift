import SwiftUI

struct PreferencesView: View {
    @AppStorage(UserSettings.reminderInterval) private var reminderInterval: Double = 2400
    @AppStorage(UserSettings.breakDuration) private var breakDuration: Double = 60

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                Text("Reminder Interval: \(Int(reminderInterval / 60)) min")
                Slider(value: $reminderInterval, in: 60...3600, step: 60) {
                    Text("Interval")
                } minimumValueLabel: {
                    Text("1 min")
                } maximumValueLabel: {
                    Text("60 min")
                }
                .onChange(of: reminderInterval) {
                    NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
                }
            }
            .padding(.bottom)

            VStack(alignment: .leading) {
                Text("Break Duration: \(Int(breakDuration)) sec")
                Slider(value: $breakDuration, in: 10...300, step: 10) {
                    Text("Duration")
                } minimumValueLabel: {
                    Text("10 sec")
                } maximumValueLabel: {
                    Text("300 sec")
                }
                .onChange(of: breakDuration) {
                    NotificationCenter.default.post(name: .preferencesDidChange, object: nil)
                }
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

extension Notification.Name {
    static let preferencesDidChange = Notification.Name("preferencesDidChange")
}
