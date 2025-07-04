
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var timer: Timer?
    var reminderWindows: [NSWindow] = []
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
        if reminderWindows.isEmpty {
            let randomRed = Double.random(in: 0...1)
            let randomGreen = Double.random(in: 0...1)
            let randomBlue = Double.random(in: 0...1)
            let backgroundColor = Color(red: randomRed, green: randomGreen, blue: randomBlue)

            for screen in NSScreen.screens {
                let screenRect = screen.visibleFrame
                let width = screenRect.width * 0.7
                let height = screenRect.height * 0.7

                let reminderView = ReminderView(width: width, height: height, initialCountdown: Int(breakDuration), backgroundColor: backgroundColor) {
                    self.closeReminder()
                }
                
                let hostingView = NSHostingView(rootView: reminderView)
                
                let newWindow = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                    styleMask: .borderless,
                    backing: .buffered,
                    defer: false
                )
                newWindow.isOpaque = false
                newWindow.backgroundColor = .clear
                newWindow.hasShadow = false
                
                let x = screenRect.origin.x + (screenRect.size.width - width) / 2
                let y = screenRect.origin.y + (screenRect.size.height - height) / 2
                newWindow.setFrameOrigin(NSPoint(x: x, y: y))

                newWindow.isReleasedWhenClosed = false
                newWindow.level = .floating
                newWindow.contentView = hostingView
                newWindow.makeKeyAndOrderFront(nil)
                
                reminderWindows.append(newWindow)
            }
        }
    }

    func closeReminder() {
        reminderWindows.forEach { $0.close() }
        reminderWindows.removeAll()
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
