import Cocoa
import SwiftUI

class SettingsPanel {
    private var panel: NSPanel?
    private let settings: SettingsManager

    init(settings: SettingsManager) {
        self.settings = settings
    }

    func show() {
        if panel == nil {
            createPanel()
        }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func createPanel() {
        let p = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 180),
            styleMask: [.titled, .closable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        p.title = "단축키 설정"
        p.level = .floating
        p.center()
        p.isReleasedWhenClosed = false

        p.contentView = NSHostingView(rootView: SettingsView(settings: settings))
        self.panel = p
    }
}
