import SwiftUI

struct HistoryView: View {
    @ObservedObject var manager: HistoryManager
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if manager.items.isEmpty {
                emptyView
            } else {
                listView
            }

            Divider()
            footer
        }
    }

    private var header: some View {
        HStack {
            Text("캡처 히스토리")
                .font(.headline)
            Spacer()
            Text("\(manager.items.count)/\(HistoryManager.maxItems)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(systemName: "text.viewfinder")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.5))
            Text("텍스트를 캡처하면 여기에 표시됩니다")
                .foregroundColor(.secondary)
            Text("\(settings.captureShortcut.displayString)로 화면의 텍스트를 캡처하세요")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                ForEach(Array(manager.items.enumerated()), id: \.offset) { index, item in
                    HistoryItemRow(
                        index: index,
                        text: item,
                        onCopy: { manager.copyItem(at: index) },
                        onDelete: { manager.removeItem(at: index) }
                    )
                }
            }
            .padding(6)
        }
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Label("\(settings.captureShortcut.displayString) 캡처", systemImage: "camera.viewfinder")
            Label("\(settings.toggleShortcut.displayString) 숨기기", systemImage: "eye.slash")
            Label("⌘1~0 복사", systemImage: "doc.on.doc")
        }
        .font(.caption2)
        .foregroundColor(.secondary)
        .padding(6)
    }
}

struct HistoryItemRow: View {
    let index: Int
    let text: String
    let onCopy: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false
    @State private var showCopied = false

    private var shortcutLabel: String {
        if index < 10 {
            return "⌘\((index + 1) % 10)"
        }
        return ""
    }

    var body: some View {
        HStack(spacing: 8) {
            if !shortcutLabel.isEmpty {
                Text(shortcutLabel)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 28, alignment: .center)
            }

            Text(text)
                .lineLimit(3)
                .font(.system(.body))
                .frame(maxWidth: .infinity, alignment: .leading)

            if showCopied {
                Text("복사됨")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }

            if isHovered {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isHovered ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onHover { isHovered = $0 }
        .onTapGesture {
            onCopy()
            withAnimation { showCopied = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation { showCopied = false }
            }
        }
    }
}
