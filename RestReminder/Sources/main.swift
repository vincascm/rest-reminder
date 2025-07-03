
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var timer: Timer?
    var reminderWindow: NSWindow?
    var statusBarItem: NSStatusItem!
    var preferencesWindow: NSWindow?

    @AppStorage("reminderInterval") var reminderInterval: Double = 120 // Default 2 minutes
    @AppStorage("breakDuration") var breakDuration: Double = 60 // Default 1 minute

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: "Rest Reminder")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu

        // Start the main timer
        startTimer()

        // Observe preference changes
        NotificationCenter.default.addObserver(self, selector: #selector(handlePreferencesChange), name: .preferencesDidChange, object: nil)
    }

    @objc func handlePreferencesChange() {
        // Restart timer with new interval
        startTimer()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: reminderInterval, target: self, selector: #selector(showReminder), userInfo: nil, repeats: true)
    }

    @objc func showReminder() {
        if reminderWindow == nil {
            guard let screen = NSScreen.main else { return }
            let screenRect = screen.visibleFrame
            let width = screenRect.width * 0.7
            let height = screenRect.height * 0.7

            let reminderView = ReminderView(width: width, height: height, initialCountdown: Int(breakDuration)) {
                self.closeReminder()
            }
            
            let hostingView = NSHostingView(rootView: reminderView)
            
            reminderWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            reminderWindow?.isOpaque = false
            reminderWindow?.backgroundColor = .clear
            reminderWindow?.hasShadow = false
            reminderWindow?.center()
            reminderWindow?.isReleasedWhenClosed = false
            reminderWindow?.level = .floating
            reminderWindow?.contentView = hostingView
            reminderWindow?.makeKeyAndOrderFront(nil)
            
            // Center the window
            if let screenSize = NSScreen.main?.visibleFrame.size {
                let windowSize = reminderWindow!.frame.size
                let x = (screenSize.width - windowSize.width) / 2
                let y = (screenSize.height - windowSize.height) / 2
                reminderWindow?.setFrameOrigin(NSPoint(x: x, y: y))
            }
        }
    }

    func closeReminder() {
        reminderWindow?.close()
        reminderWindow = nil
    }

    @objc func showPreferences() {
        if preferencesWindow == nil {
            let preferencesView = PreferencesView()
            let hostingView = NSHostingView(rootView: preferencesView)
            
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            preferencesWindow?.center()
            preferencesWindow?.isReleasedWhenClosed = false
            preferencesWindow?.contentView = hostingView
            preferencesWindow?.makeKeyAndOrderFront(nil)
            preferencesWindow?.delegate = self // Set delegate

            // Bring app to front and make it active
            NSApp.activate(ignoringOtherApps: true)
            NSApp.setActivationPolicy(.regular)
        }
    }

    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow == preferencesWindow {
            preferencesWindow = nil
            // Revert activation policy when preferences window closes
            NSApp.setActivationPolicy(.accessory)
            NSApp.hide(nil)
        }
    }
}

// Main application setup
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
