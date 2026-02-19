import SwiftUI
import Carbon

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(spacing: 16) {
            Text("단축키 설정")
                .font(.headline)
                .padding(.top, 8)

            VStack(spacing: 12) {
                HStack {
                    Text("텍스트 캡처")
                        .frame(width: 100, alignment: .trailing)
                    ShortcutRecorderButton(
                        shortcut: settings.captureShortcut,
                        onRecord: { config in
                            settings.updateCaptureShortcut(config)
                        }
                    )
                }

                HStack {
                    Text("히스토리 토글")
                        .frame(width: 100, alignment: .trailing)
                    ShortcutRecorderButton(
                        shortcut: settings.toggleShortcut,
                        onRecord: { config in
                            settings.updateToggleShortcut(config)
                        }
                    )
                }
            }

            Button("기본값으로 초기화") {
                settings.resetToDefaults()
            }
            .buttonStyle(.link)
            .padding(.bottom, 8)
        }
        .padding(20)
        .frame(width: 320)
    }
}

struct ShortcutRecorderButton: View {
    let shortcut: ShortcutConfig
    let onRecord: (ShortcutConfig) -> Void

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        Button(action: {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        }) {
            Text(isRecording ? "키 입력 대기중..." : shortcut.displayString)
                .frame(minWidth: 140)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isRecording ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        isRecording = true
        HotKeyManager.shared?.unregisterHotKeys()

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                HotKeyManager.shared?.reregisterHotKeys()
                return nil
            }

            let mods = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !mods.isEmpty else { return event }

            let carbonMods = ShortcutConfig.carbonModifiers(from: event.modifierFlags)
            let config = ShortcutConfig(keyCode: UInt32(event.keyCode), modifiers: carbonMods)
            onRecord(config)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
