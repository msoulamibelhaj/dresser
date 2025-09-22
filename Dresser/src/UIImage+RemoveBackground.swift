import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

extension UIImage {
    /// Remove background asynchronously (iOS 17+ only)
    func removeBackground(completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = self.cgImage else {
            completion(nil)
            return
        }
        
        let ciContext = CIContext()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let request = VNGenerateForegroundInstanceMaskRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
                guard let obs = request.results?.first as? VNInstanceMaskObservation else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                do {
                    // Generate a high-res mask
                    let maskBuffer = try obs.generateScaledMaskForImage(forInstances: obs.allInstances, from: handler)
                    let maskCI = CIImage(cvPixelBuffer: maskBuffer)
                    let originalCI = CIImage(cgImage: cgImage)
                    
                    // Create transparent background
                    let alphaBackground = CIImage(color: .clear).cropped(to: originalCI.extent)
                    
                    let filter = CIFilter.blendWithMask()
                    filter.inputImage = originalCI
                    filter.backgroundImage = alphaBackground
                    filter.maskImage = maskCI
                    
                    guard let outputCI = filter.outputImage,
                          let outputCG = ciContext.createCGImage(outputCI, from: outputCI.extent) else {
                        DispatchQueue.main.async { completion(nil) }
                        return
                    }
                    
                    let out = UIImage(
                        cgImage: outputCG,
                        scale: self.scale,
                        orientation: self.imageOrientation
                    )
                    DispatchQueue.main.async { completion(out) }
                    
                } catch {
                    print("Mask generation failed:", error)
                    DispatchQueue.main.async { completion(nil) }
                }
            } catch {
                print("Vision perform error:", error)
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
