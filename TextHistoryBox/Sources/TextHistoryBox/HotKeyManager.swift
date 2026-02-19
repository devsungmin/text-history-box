import Carbon
import Cocoa

class HotKeyManager {
    static var shared: HotKeyManager?

    private var hotKeyRefs: [EventHotKeyRef?] = []
    private let onCapture: () -> Void
    private let onToggleHistory: () -> Void
    private let settings: SettingsManager

    init(settings: SettingsManager, onCapture: @escaping () -> Void, onToggleHistory: @escaping () -> Void) {
        self.settings = settings
        self.onCapture = onCapture
        self.onToggleHistory = onToggleHistory
        HotKeyManager.shared = self

        installEventHandler()
        registerHotKeys()

        settings.onShortcutsChanged = { [weak self] in
            self?.reregisterHotKeys()
        }
    }

    private func installEventHandler() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyEventHandler,
            1,
            &eventType,
            nil,
            nil
        )
    }

    func registerHotKeys() {
        // ⌘⇧2: 텍스트 캡처 (기본값, 사용자 설정 가능)
        registerHotKey(
            keyCode: settings.captureShortcut.keyCode,
            modifiers: settings.captureShortcut.modifiers,
            id: 1
        )

        // ⌘⇧H: 히스토리 토글 (기본값, 사용자 설정 가능)
        registerHotKey(
            keyCode: settings.toggleShortcut.keyCode,
            modifiers: settings.toggleShortcut.modifiers,
            id: 2
        )
    }

    func unregisterHotKeys() {
        for ref in hotKeyRefs {
            if let ref = ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotKeyRefs.removeAll()
    }

    func reregisterHotKeys() {
        unregisterHotKeys()
        registerHotKeys()
    }

    private func registerHotKey(keyCode: UInt32, modifiers: UInt32, id: UInt32) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: 0x54484258, id: id)

        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr {
            hotKeyRefs.append(hotKeyRef)
        }
    }

    func handleHotKey(id: UInt32) {
        switch id {
        case 1: onCapture()
        case 2: onToggleHistory()
        default: break
        }
    }
}

private func hotKeyEventHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    guard status == noErr else { return status }

    HotKeyManager.shared?.handleHotKey(id: hotKeyID.id)
    return noErr
}
