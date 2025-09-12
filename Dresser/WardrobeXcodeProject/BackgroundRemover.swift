import Foundation
import UIKit
import Vision
import CoreImage

// Background removal using Vision person segmentation.
// Note: VNGeneratePersonSegmentationRequest is primarily for people/mannequins.
public class BackgroundRemover {
    static let ciContext = CIContext(options: nil)

    /// Remove background, returning a UIImage with alpha (transparent background) or nil on failure.
    public static func removeBackground(from input: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cg = input.cgImage else { completion(nil); return }
        let req = VNGeneratePersonSegmentationRequest()
        req.qualityLevel = .accurate
        req.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cgImage: cg, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([req])
                guard let observation = req.results?.first as? VNPixelBufferObservation else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                let maskBuffer = observation.pixelBuffer
                let result = applyMask(pixelBuffer: maskBuffer, to: input)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("Vision error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }

    // Apply single-channel mask pixel buffer to an image, producing a UIImage with alpha.
    private static func applyMask(pixelBuffer: CVPixelBuffer, to image: UIImage) -> UIImage? {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let maskCI = CIImage(cvPixelBuffer: pixelBuffer)
        let sourceCI = CIImage(image: image)

        // Resize mask to image size
        let maskExtent = maskCI.extent
        guard let sCI = sourceCI else { return nil }
        let targetSize = sCI.extent.size
        let scaleX = targetSize.width / maskExtent.width
        let scaleY = targetSize.height / maskExtent.height
        let scaledMask = maskCI.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // Convert mask (single channel) -> alpha mask by normalizing and converting to RGBA
        // Use CIBlendWithMask to composite image over transparent background.
        let transparent = CIImage(color: .clear).cropped(to: sCI.extent)
        guard let blended = sCI.composited(over: transparent).applyingFilter("CIBlendWithMask", parameters: [
            "inputMaskImage": scaledMask
        ]) else {
            // Fallback: try manual compositing
            return nil
        }

        if let outCG = ciContext.createCGImage(blended, from: blended.extent) {
            return UIImage(cgImage: outCG, scale: image.scale, orientation: image.imageOrientation)
        }
        return nil
    }
}
