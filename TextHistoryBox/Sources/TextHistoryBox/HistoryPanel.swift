import Cocoa
import SwiftUI

class HistoryPanel {
    private var panel: KeyablePanel?
    private let historyManager: HistoryManager
    private let settings: SettingsManager
    private var localMonitor: Any?

    init(historyManager: HistoryManager, settings: SettingsManager) {
        self.historyManager = historyManager
        self.settings = settings
    }

    func toggle() {
        if let panel = panel, panel.isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            createPanel()
        }
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        startKeyMonitor()
    }

    func hide() {
        panel?.orderOut(nil)
        stopKeyMonitor()
    }

    private func createPanel() {
        let p = KeyablePanel(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 500),
            styleMask: [.titled, .closable, .resizable, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        p.title = "Text History Box"
        p.level = .floating
        p.isFloatingPanel = true
        p.hidesOnDeactivate = false
        p.center()
        p.isReleasedWhenClosed = false

        let hostingView = NSHostingView(rootView: HistoryView(manager: historyManager, settings: settings))
        p.contentView = hostingView
        p.contentMinSize = NSSize(width: 300, height: 200)

        self.panel = p
    }

    private func startKeyMonitor() {
        guard localMonitor == nil else { return }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self,
                  self.panel?.isKeyWindow == true else { return event }

            // Escape로 닫기
            if event.keyCode == 53 {
                self.hide()
                return nil
            }

            // ⌘ + 숫자로 복사
            if event.modifierFlags.contains(.command),
               let index = self.indexFromKeyCode(event.keyCode) {
                self.historyManager.copyItem(at: index)
                return nil
            }

            return event
        }
    }

    private func stopKeyMonitor() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    /// 키코드를 히스토리 인덱스(0-based)로 변환
    private func indexFromKeyCode(_ keyCode: UInt16) -> Int? {
        switch keyCode {
        case 18: return 0  // 1
        case 19: return 1  // 2
        case 20: return 2  // 3
        case 21: return 3  // 4
        case 23: return 4  // 5
        case 22: return 5  // 6
        case 26: return 6  // 7
        case 28: return 7  // 8
        case 25: return 8  // 9
        case 29: return 9  // 0
        default: return nil
        }
    }
}

class KeyablePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
