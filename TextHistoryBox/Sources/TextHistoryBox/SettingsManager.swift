import Cocoa
import Carbon

struct ShortcutConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32

    var displayString: String {
        var result = ""
        if modifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { result += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { result += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { result += "⌘" }
        result += Self.keyCodeToString(keyCode)
        return result
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var mods: UInt32 = 0
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        if flags.contains(.shift) { mods |= UInt32(shiftKey) }
        if flags.contains(.option) { mods |= UInt32(optionKey) }
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        return mods
    }

    static func keyCodeToString(_ keyCode: UInt32) -> String {
        switch Int(keyCode) {
        case kVK_ANSI_A: return "A"
        case kVK_ANSI_S: return "S"
        case kVK_ANSI_D: return "D"
        case kVK_ANSI_F: return "F"
        case kVK_ANSI_H: return "H"
        case kVK_ANSI_G: return "G"
        case kVK_ANSI_Z: return "Z"
        case kVK_ANSI_X: return "X"
        case kVK_ANSI_C: return "C"
        case kVK_ANSI_V: return "V"
        case kVK_ANSI_B: return "B"
        case kVK_ANSI_Q: return "Q"
        case kVK_ANSI_W: return "W"
        case kVK_ANSI_E: return "E"
        case kVK_ANSI_R: return "R"
        case kVK_ANSI_Y: return "Y"
        case kVK_ANSI_T: return "T"
        case kVK_ANSI_1: return "1"
        case kVK_ANSI_2: return "2"
        case kVK_ANSI_3: return "3"
        case kVK_ANSI_4: return "4"
        case kVK_ANSI_5: return "5"
        case kVK_ANSI_6: return "6"
        case kVK_ANSI_7: return "7"
        case kVK_ANSI_8: return "8"
        case kVK_ANSI_9: return "9"
        case kVK_ANSI_0: return "0"
        case kVK_ANSI_Equal: return "="
        case kVK_ANSI_Minus: return "-"
        case kVK_ANSI_RightBracket: return "]"
        case kVK_ANSI_LeftBracket: return "["
        case kVK_ANSI_Quote: return "'"
        case kVK_ANSI_Semicolon: return ";"
        case kVK_ANSI_Backslash: return "\\"
        case kVK_ANSI_Comma: return ","
        case kVK_ANSI_Slash: return "/"
        case kVK_ANSI_Period: return "."
        case kVK_ANSI_Grave: return "`"
        case kVK_ANSI_O: return "O"
        case kVK_ANSI_U: return "U"
        case kVK_ANSI_I: return "I"
        case kVK_ANSI_P: return "P"
        case kVK_ANSI_L: return "L"
        case kVK_ANSI_J: return "J"
        case kVK_ANSI_K: return "K"
        case kVK_ANSI_N: return "N"
        case kVK_ANSI_M: return "M"
        case kVK_Space: return "Space"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Delete: return "⌫"
        case kVK_ForwardDelete: return "⌦"
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        default: return "?"
        }
    }
}

class SettingsManager: ObservableObject {
    static let defaultCaptureShortcut = ShortcutConfig(
        keyCode: UInt32(kVK_ANSI_2),
        modifiers: UInt32(cmdKey | shiftKey)
    )
    static let defaultToggleShortcut = ShortcutConfig(
        keyCode: UInt32(kVK_ANSI_H),
        modifiers: UInt32(cmdKey | shiftKey)
    )

    @Published var captureShortcut: ShortcutConfig
    @Published var toggleShortcut: ShortcutConfig

    var onShortcutsChanged: (() -> Void)?

    init() {
        if let data = UserDefaults.standard.data(forKey: "captureShortcut"),
           let config = try? JSONDecoder().decode(ShortcutConfig.self, from: data) {
            captureShortcut = config
        } else {
            captureShortcut = Self.defaultCaptureShortcut
        }

        if let data = UserDefaults.standard.data(forKey: "toggleShortcut"),
           let config = try? JSONDecoder().decode(ShortcutConfig.self, from: data) {
            toggleShortcut = config
        } else {
            toggleShortcut = Self.defaultToggleShortcut
        }
    }

    func updateCaptureShortcut(_ config: ShortcutConfig) {
        captureShortcut = config
        save(config, forKey: "captureShortcut")
        onShortcutsChanged?()
    }

    func updateToggleShortcut(_ config: ShortcutConfig) {
        toggleShortcut = config
        save(config, forKey: "toggleShortcut")
        onShortcutsChanged?()
    }

    func resetToDefaults() {
        updateCaptureShortcut(Self.defaultCaptureShortcut)
        updateToggleShortcut(Self.defaultToggleShortcut)
    }

    private func save(_ config: ShortcutConfig, forKey key: String) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
