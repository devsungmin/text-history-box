import Cocoa

class HistoryManager: ObservableObject {
    static let maxItems = 20

    @Published var items: [String] = []

    func addItem(_ text: String) {
        // 이미 존재하면 제거 후 맨 앞으로
        items.removeAll { $0 == text }
        items.insert(text, at: 0)

        if items.count > Self.maxItems {
            items = Array(items.prefix(Self.maxItems))
        }
    }

    func copyItem(at index: Int) {
        guard index >= 0, index < items.count else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(items[index], forType: .string)
    }

    func removeItem(at index: Int) {
        guard index >= 0, index < items.count else { return }
        items.remove(at: index)
    }
}
