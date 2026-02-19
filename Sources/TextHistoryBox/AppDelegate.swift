import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let historyManager = HistoryManager()
    private let settingsManager = SettingsManager()
    private var historyPanel: HistoryPanel!
    private var settingsPanel: SettingsPanel!
    private var hotKeyManager: HotKeyManager!
    private let captureManager = ScreenCaptureManager()
    private let toast = ToastPanel()

    private var captureMenuItem: NSMenuItem!
    private var toggleMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        historyPanel = HistoryPanel(historyManager: historyManager, settings: settingsManager)
        settingsPanel = SettingsPanel(settings: settingsManager)
        setupHotKeys()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "text.viewfinder",
                accessibilityDescription: "Text History Box"
            )
        }

        let menu = NSMenu()

        captureMenuItem = menu.addItem(
            withTitle: "텍스트 캡처 (\(settingsManager.captureShortcut.displayString))",
            action: #selector(captureText),
            keyEquivalent: ""
        )

        toggleMenuItem = menu.addItem(
            withTitle: "히스토리 보기/숨기기 (\(settingsManager.toggleShortcut.displayString))",
            action: #selector(toggleHistory),
            keyEquivalent: ""
        )

        menu.addItem(NSMenuItem.separator())

        menu.addItem(
            withTitle: "단축키 설정...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )

        menu.addItem(
            withTitle: "히스토리 초기화",
            action: #selector(clearHistory),
            keyEquivalent: ""
        )

        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            withTitle: "종료",
            action: #selector(quit),
            keyEquivalent: "q"
        )

        statusItem.menu = menu
    }

    private func setupHotKeys() {
        hotKeyManager = HotKeyManager(
            settings: settingsManager,
            onCapture: { [weak self] in self?.captureText() },
            onToggleHistory: { [weak self] in self?.toggleHistory() }
        )

        settingsManager.onShortcutsChanged = { [weak self] in
            self?.hotKeyManager.reregisterHotKeys()
            self?.updateMenuTitles()
        }
    }

    private func updateMenuTitles() {
        captureMenuItem?.title = "텍스트 캡처 (\(settingsManager.captureShortcut.displayString))"
        toggleMenuItem?.title = "히스토리 보기/숨기기 (\(settingsManager.toggleShortcut.displayString))"
    }

    @objc private func captureText() {
        captureManager.captureAndRecognize { [weak self] text in
            guard let text = text, !text.isEmpty else { return }
            self?.historyManager.addItem(text)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
            self?.toast.show("텍스트가 복사되었습니다")
        }
    }

    @objc private func toggleHistory() {
        historyPanel.toggle()
    }

    @objc private func openSettings() {
        settingsPanel.show()
    }

    @objc private func clearHistory() {
        historyManager.items.removeAll()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
