
import Foundation
import UIKit
import AVFoundation
import Vision
import QKMRZParser
import IdentifyIOS

@available(iOS 13.0, *)
class VisionViewController: SDKMrzViewController {
	var request: VNRecognizeTextRequest!
	let mrzTracker = StringTracker()
	
	override func viewDidLoad() {
		request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

		super.viewDidLoad()
	}
	
	// MARK: - Text recognition
	
	// Vision recognition handler.
	func recognizeTextHandler(request: VNRequest, error: Error?) {
		var redBoxes = [CGRect]() // Shows all recognized text lines
		var greenBoxes = [CGRect]() // Shows words that might be serials
        var codes = [String]()

		guard let results = request.results as? [VNRecognizedTextObservation] else {
			return
		}
		
		let maximumCandidates = 1
		for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
			
			var numberIsSubstring = true

			if let result = candidate.string.checkMrz() {
                if(result != "nil") {
                    codes.append(result)
                    numberIsSubstring = false
                    greenBoxes.append(visionResult.boundingBox)
                }
			}

			if numberIsSubstring {
				redBoxes.append(visionResult.boundingBox)
			}
		}
		
		// Log any found numbers.
        mrzTracker.logFrame(strings: codes)
		show(boxGroups: [(color: UIColor.red.cgColor, boxes: redBoxes), (color: UIColor.green.cgColor, boxes: greenBoxes)])
		// Check if we have any temporally stable numbers.
		if let sureNumber = mrzTracker.getStableString() {
            var newString = sureNumber
            if newString.count == 89 { // pasaport
                if sureNumber[45] == "0" {
                    newString = replaceBigZero(myString: newString, 45, "O")
                } else if sureNumber[45] == "1" {
                    newString = replaceBigZero(myString: newString, 45, "I")
                } else if sureNumber[45] == "2" {
                    newString = replaceBigZero(myString: newString, 45, "Z")
                }
                
                if sureNumber[65] == "0" {
                    newString = replaceBigZero(myString: newString, 65, "O")
                } else if sureNumber[65] == "1" {
                    newString = replaceBigZero(myString: newString, 65, "I")
                } else if sureNumber[65] == "2" {
                    newString = replaceBigZero(myString: newString, 65, "Z")
                }
            } else { // kimlik
                if sureNumber[5] == "0" {
                    newString = replaceBigZero(myString: sureNumber, 5, "O")
                } else if sureNumber[5] == "1" {
                    newString = replaceBigZero(myString: sureNumber, 5, "I")
                } else if sureNumber[5] == "2" {
                    newString = replaceBigZero(myString: sureNumber, 5, "Z")
                }
                
                if sureNumber[8] == "0" {
                    newString = replaceBigZero(myString: sureNumber, 8, "O")
                } else if sureNumber[8] == "1" {
                    newString = replaceBigZero(myString: sureNumber, 8, "I")
                } else if sureNumber[8] == "2" {
                    newString = replaceBigZero(myString: sureNumber, 8, "Z")
                }
                
                if sureNumber[37] == "0" {
                    newString = replaceBigZero(myString: newString, 37, "O")
                } else if sureNumber[37] == "1" {
                    newString = replaceBigZero(myString: newString, 37, "I")
                } else if sureNumber[37] == "2" {
                    newString = replaceBigZero(myString: newString, 37, "Z")
                }
            }
            
			showString(string: newString)
            
            var stringArray = [String]()
            
            let explodeN = newString.split(separator: "\n")
            
            for n in explodeN {
                stringArray.append(String(n))
            }
            
            let mrzData = stringArray
            let mrzParser = QKMRZParser(ocrCorrection: true)
            let result = mrzParser.parse(mrzLines: mrzData)
            if result != nil {
                
                let passportModel = PassportModel(documentNumber: result?.documentNumber ?? "", birthDate: result?.birthDate ?? Date(), expiryDate: result?.expiryDate ?? Date())
                delegate?.processNew(scanResult: passportModel, barcodeString: sureNumber)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.dismiss(animated: true) {
                        self.mrzTracker.reset(string: sureNumber)
                    }
                }
            }
            
		}
	}
	
	override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
			// Configure for running in real-time.
			request.recognitionLevel = .fast
			// Language correction won't help recognizing phone numbers. It also
			// makes recognition slower.
			request.usesLanguageCorrection = false
			// Only run on the region of interest for maximum speed.
			request.regionOfInterest = regionOfInterest
			
			let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
			do {
				try requestHandler.perform([request])
			} catch {
				print(error)
			}
		}
	}
	
	// MARK: - Bounding box drawing
	
	// Draw a box on screen. Must be called from main queue.
	var boxLayer = [CAShapeLayer]()
	func draw(rect: CGRect, color: CGColor) {
		let layer = CAShapeLayer()
		layer.opacity = 0.5
		layer.borderColor = color
		layer.borderWidth = 1
		layer.frame = rect
		boxLayer.append(layer)
		previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
	}
	
	// Remove all drawn boxes. Must be called on main queue.
	func removeBoxes() {
        if boxLayer.count > 0 {
            for layer in boxLayer {
                layer.removeFromSuperlayer()
            }
            boxLayer.removeAll()
        }
	}
    
    func replaceBigZero(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
	
	typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
	
	// Draws groups of colored boxes.
	func show(boxGroups: [ColoredBoxGroup]) {
		DispatchQueue.main.async {
			let layer = self.previewView.videoPreviewLayer
			self.removeBoxes()
			for boxGroup in boxGroups {
				let color = boxGroup.color
				for box in boxGroup.boxes {
					let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
					self.draw(rect: rect, color: color)
				}
			}
		}
	}

}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
