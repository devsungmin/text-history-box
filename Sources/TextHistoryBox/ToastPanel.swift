import Cocoa
import SwiftUI

class ToastPanel {
    private var panel: NSPanel?
    private var dismissTimer: Timer?

    func show(_ message: String) {
        dismiss()

        let view = NSHostingView(rootView: ToastView(message: message))
        view.frame = NSRect(x: 0, y: 0, width: 260, height: 50)

        let p = NSPanel(
            contentRect: view.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .statusBar
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = true
        p.contentView = view
        p.isReleasedWhenClosed = false

        if let screen = NSScreen.main {
            let x = screen.frame.midX - p.frame.width / 2
            let y = screen.frame.maxY - 120
            p.setFrameOrigin(NSPoint(x: x, y: y))
        }

        p.alphaValue = 0
        p.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            p.animator().alphaValue = 1
        }

        self.panel = p
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.dismiss()
        }
    }

    private func dismiss() {
        dismissTimer?.invalidate()
        dismissTimer = nil

        guard let p = panel else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            p.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            p.orderOut(nil)
            self?.panel = nil
        })
    }
}

private struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .lineLimit(1)
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.75))
        )
    }
}
