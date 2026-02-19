import Cocoa
import Vision

class ScreenCaptureManager {
    func captureAndRecognize(completion: @escaping (String?) -> Void) {
        let tempFile = NSTemporaryDirectory() + "thb_capture_\(UUID().uuidString).png"

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
        process.arguments = ["-i", "-x", tempFile] // -i: 영역 선택, -x: 소리 없음

        process.terminationHandler = { [weak self] _ in
            defer { try? FileManager.default.removeItem(atPath: tempFile) }

            guard FileManager.default.fileExists(atPath: tempFile),
                  let image = NSImage(contentsOfFile: tempFile),
                  let tiffData = image.tiffRepresentation,
                  let bitmap = NSBitmapImageRep(data: tiffData),
                  let cgImage = bitmap.cgImage
            else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self?.recognizeText(in: cgImage, completion: completion)
        }

        do {
            try process.run()
        } catch {
            completion(nil)
        }
    }

    private func recognizeText(in image: CGImage, completion: @escaping (String?) -> Void) {
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            DispatchQueue.main.async {
                completion(text.isEmpty ? nil : text)
            }
        }

        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: image, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
