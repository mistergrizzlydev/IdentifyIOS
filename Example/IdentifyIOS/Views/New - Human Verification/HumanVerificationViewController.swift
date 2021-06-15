//
//  HumanVerificationViewController.swift
//  IdentifyIOS_Example
//
//  Created by Emir Beytekin on 15.06.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import IdentifyIOS
import MLKit
import AVFoundation


class HumanVerificationViewController: SDKBaseViewController, PopUpProtocol {
    
    let manager = IdentifyManager.shared
    weak var delegate: SmileDelegate?
    
    private let detectors: [Detector] = [
      .onDeviceFace
    ]
    
    private var currentDetector: Detector = .onDeviceFace
    private var isUsingFrontCamera = true
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private lazy var captureSession = AVCaptureSession()
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)
    private var lastFrame: CMSampleBuffer?
    private var currentStep = 0

    private lazy var previewOverlayView: UIImageView = {
      precondition(isViewLoaded)
      let previewOverlayView = UIImageView(frame: .zero)
      previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
      previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return previewOverlayView
    }()

    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    /// The detector mode with which detection was most recently run. Only used on the video output
    /// queue. Useful for inferring when to reset detector instances which use a conventional
    /// lifecyle paradigm.
    private var lastDetector: Detector?
    
    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    
    private var firstStart = true
    private var leftEyeBlinkOk = false
    private var rightEyeBlinkOk = false
    private var headTurnLeftOk = false
    private var headTurnRightOk = false
    private var smileOk = false

    override func viewDidLoad() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.setUpPreviewOverlayView()
        self.setUpAnnotationOverlayView()
        self.setUpCaptureSessionOutput()
        self.setUpCaptureSessionInput()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showStepPopUp(step: .leftEye)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      stopSession()
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      previewLayer.frame = cameraView.frame
    }
    
    func handlePopUpAction(action: Bool) {
        startSession()
    }
    
    func showStepPopUp(step: Dialogs) {
        stopSession()
        self.statusLbl.text = step.rawValue
        self.showPopUp(image: UIImage(named: "ob3")!, desc: step.rawValue)
    }
    
    private func detectFacesOnDevice(in image: VisionImage, width: CGFloat, height: CGFloat) {
      // When performing latency tests to determine ideal detection settings, run the app in 'release'
      // mode to get accurate performance metrics.
      let options = FaceDetectorOptions()
      options.landmarkMode = .none
      options.contourMode = .none
      options.classificationMode = .all
      options.performanceMode = .fast
      let faceDetector = FaceDetector.faceDetector(options: options)
      var faces: [Face]
      do {
        faces = try faceDetector.results(in: image)
      } catch let error {
        print("Failed to detect faces with error: \(error.localizedDescription).")
        return
      }
      weak var weakSelf = self
      DispatchQueue.main.sync {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.updatePreviewOverlayViewWithLastFrame()
        strongSelf.removeDetectionAnnotations()
      }
      guard !faces.isEmpty else {
//        print("On-Device face detector returned no results.")
        return
      }
      DispatchQueue.main.sync {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        for face in faces {
          let normalizedRect = CGRect(
            x: face.frame.origin.x / width,
            y: face.frame.origin.y / height,
            width: face.frame.size.width / width,
            height: face.frame.size.height / height
          )
          let standardizedRect = strongSelf.previewLayer.layerRectConverted(
            fromMetadataOutputRect: normalizedRect
          ).standardized
          
          let frame = face.frame
                
            if leftEyeBlinkOk == false && currentStep == 0 {
                let leftEyeOpenProb = face.leftEyeOpenProbability
                if leftEyeOpenProb < 0.4 {
                    currentStep += 1
                    leftEyeBlinkOk = true
                    showStepPopUp(step: .rightEye)
                }
            } else if leftEyeBlinkOk == true && rightEyeBlinkOk == false && currentStep == 1 {
                if face.hasRightEyeOpenProbability {
                  let rightEyeOpenProb = face.rightEyeOpenProbability
                  if rightEyeOpenProb < 0.4 {
                    currentStep += 1
                    rightEyeBlinkOk = true
                    showStepPopUp(step: .headLeft)
                  }
                }
            } else if rightEyeBlinkOk == true && headTurnLeftOk == false && currentStep == 2 {
                if face.hasHeadEulerAngleY {
                    let rotY = face.headEulerAngleY
                    if rotY < -40 {
                        currentStep += 1
                        headTurnLeftOk = true
                        showStepPopUp(step: .headRight)
                    }
                }
            } else if headTurnLeftOk == true && headTurnRightOk == false && currentStep == 3 {
                if face.hasHeadEulerAngleY {
                    let rotY = face.headEulerAngleY
                    if rotY > 40 {
                        currentStep += 1
                        headTurnRightOk = true
                        showStepPopUp(step: .plsSmie)
                    }
                }
            } else if headTurnRightOk ==  true && smileOk == false && currentStep == 4 {
                if face.hasSmilingProbability {
                  let smileProb = face.smilingProbability
                  if smileProb > 0.8 {
                    DispatchQueue.main.async {
                        self.delegate?.smileCompleted()
                        self.dismiss(animated: true, completion: nil)
                    }
                  }
                }
            }
        }
      }
    }

    // MARK: - Private

    private func setUpCaptureSessionOutput() {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.captureSession.beginConfiguration()
        // When performing latency tests to determine ideal capture settings,
        // run the app in 'release' mode to get accurate performance metrics
        strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
          (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
        ]
        output.alwaysDiscardsLateVideoFrames = true
        let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
        output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
        guard strongSelf.captureSession.canAddOutput(output) else {
          print("Failed to add capture session output.")
          return
        }
        strongSelf.captureSession.addOutput(output)
        strongSelf.captureSession.commitConfiguration()
      }
    }

    private func setUpCaptureSessionInput() {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        let cameraPosition: AVCaptureDevice.Position = strongSelf.isUsingFrontCamera ? .front : .back
        guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
          print("Failed to get capture device for camera position: \(cameraPosition)")
          return
        }
        do {
          strongSelf.captureSession.beginConfiguration()
          let currentInputs = strongSelf.captureSession.inputs
          for input in currentInputs {
            strongSelf.captureSession.removeInput(input)
          }

          let input = try AVCaptureDeviceInput(device: device)
          guard strongSelf.captureSession.canAddInput(input) else {
            print("Failed to add capture session input.")
            return
          }
          strongSelf.captureSession.addInput(input)
          strongSelf.captureSession.commitConfiguration()
        } catch {
          print("Failed to create capture device input: \(error.localizedDescription)")
        }
      }
    }

    private func startSession() {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.captureSession.startRunning()
      }
    }

    private func stopSession() {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.captureSession.stopRunning()
      }
    }

    private func setUpPreviewOverlayView() {
      cameraView.addSubview(previewOverlayView)
      NSLayoutConstraint.activate([
        previewOverlayView.centerXAnchor.constraint(equalTo: cameraView.centerXAnchor),
        previewOverlayView.centerYAnchor.constraint(equalTo: cameraView.centerYAnchor),
        previewOverlayView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
        previewOverlayView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),

      ])
    }

    private func setUpAnnotationOverlayView() {
      cameraView.addSubview(annotationOverlayView)
      NSLayoutConstraint.activate([
        annotationOverlayView.topAnchor.constraint(equalTo: cameraView.topAnchor),
        annotationOverlayView.leadingAnchor.constraint(equalTo: cameraView.leadingAnchor),
        annotationOverlayView.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
        annotationOverlayView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
      ])
    }

    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
      if #available(iOS 10.0, *) {
        let discoverySession = AVCaptureDevice.DiscoverySession(
          deviceTypes: [.builtInWideAngleCamera],
          mediaType: .video,
          position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
      }
      return nil
    }

    private func presentDetectorsAlertController() {
      let alertController = UIAlertController(
        title: Constant.alertControllerTitle,
        message: Constant.alertControllerMessage,
        preferredStyle: .alert
      )
      weak var weakSelf = self
      detectors.forEach { detectorType in
        let action = UIAlertAction(title: detectorType.rawValue, style: .default) {
          [unowned self] (action) in
          guard let value = action.title else { return }
          guard let detector = Detector(rawValue: value) else { return }
          guard let strongSelf = weakSelf else {
            print("Self is nil!")
            return
          }
          strongSelf.currentDetector = detector
          strongSelf.removeDetectionAnnotations()
        }
        if detectorType.rawValue == self.currentDetector.rawValue { action.isEnabled = false }
        alertController.addAction(action)
      }
      alertController.addAction(UIAlertAction(title: Constant.cancelActionTitleText, style: .cancel))
      present(alertController, animated: true)
    }

    private func removeDetectionAnnotations() {
      for annotationView in annotationOverlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }

    private func updatePreviewOverlayViewWithLastFrame() {
      guard let lastFrame = lastFrame,
        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
      else {
        return
      }
      self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
    }

    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
      guard let imageBuffer = imageBuffer else {
        return
      }
      let orientation: UIImage.Orientation = isUsingFrontCamera ? .leftMirrored : .right
      let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
      previewOverlayView.image = image
    }

    private func convertedPoints(from points: [NSValue]?, width: CGFloat, height: CGFloat) -> [NSValue]? {
      return points?.map {
        let cgPointValue = $0.cgPointValue
        let normalizedPoint = CGPoint(x: cgPointValue.x / width, y: cgPointValue.y / height)
        let cgPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
        let value = NSValue(cgPoint: cgPoint)
        return value
      }
    }

    private func normalizedPoint(fromVisionPoint point: VisionPoint, width: CGFloat, height: CGFloat) -> CGPoint {
      let cgPoint = CGPoint(x: point.x, y: point.y)
      var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
      normalizedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
      return normalizedPoint
    }

    /// Resets any detector instances which use a conventional lifecycle paradigm. This method is
    /// expected to be invoked on the AVCaptureOutput queue - the same queue on which detection is
    /// run.
    private func resetManagedLifecycleDetectors(activeDetector: Detector) {
      if activeDetector == self.lastDetector {
        // Same row as before, no need to reset any detectors.
        return
      }
      // Clear the old detector, if applicable.
      switch self.lastDetector {
     
      default:
        break
      }
      // Initialize the new detector, if applicable.
      switch activeDetector {
      default:
        break
      }
      self.lastDetector = activeDetector
    }

    private func rotate(_ view: UIView, orientation: UIImage.Orientation) {
      var degree: CGFloat = 0.0
      switch orientation {
      case .up, .upMirrored:
        degree = 90.0
      case .rightMirrored, .left:
        degree = 180.0
      case .down, .downMirrored:
        degree = 270.0
      case .leftMirrored, .right:
        degree = 0.0
      }
      view.transform = CGAffineTransform.init(rotationAngle: degree * 3.141592654 / 180)
    }


}



// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension HumanVerificationViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput( _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          print("Failed to get image buffer from sample buffer.")
          return
        }
        // Evaluate `self.currentDetector` once to ensure consistency throughout this method since it
        // can be concurrently modified from the main thread.
        let activeDetector = self.currentDetector
        resetManagedLifecycleDetectors(activeDetector: activeDetector)

        lastFrame = sampleBuffer
        let visionImage = VisionImage(buffer: sampleBuffer)
        let orientation = UIUtilities.imageOrientation(
          fromDevicePosition: isUsingFrontCamera ? .front : .back
        )

        visionImage.orientation = orientation
        let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
        let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))

        switch activeDetector {
        case .onDeviceFace:
          detectFacesOnDevice(in: visionImage, width: imageWidth, height: imageHeight)
        }
    }
}




// MARK: - Constants

public enum Detector: String {
    case onDeviceFace = "Face Detection"
}

private enum Constant {
    static let alertControllerTitle = "Vision Detectors"
    static let alertControllerMessage = "Select a detector"
    static let cancelActionTitleText = "Cancel"
    static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
    static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
    static let noResultsMessage = "No Results"
    static let localModelFile = (name: "bird", type: "tflite")
    static let labelConfidenceThreshold = 0.75
    static let smallDotRadius: CGFloat = 4.0
    static let lineWidth: CGFloat = 3.0
    static let originalScale: CGFloat = 1.0
    static let padding: CGFloat = 10.0
    static let resultsLabelHeight: CGFloat = 200.0
    static let resultsLabelLines = 5
    static let imageLabelResultFrameX = 0.4
    static let imageLabelResultFrameY = 0.1
    static let imageLabelResultFrameWidth = 0.5
    static let imageLabelResultFrameHeight = 0.8
    static let segmentationMaskAlpha: CGFloat = 0.5
}

enum Dialogs: String {
    case leftEye = "Tamam tuşuna basın ve SOL gözünüzü kırpın"
    case rightEye = "Tamam tuşuna basın ve SAĞ gözünüzü kırpın"
    case headLeft = "Tamam tuşuna basın ve kafanızı SOLA çevirin"
    case headRight = "Tamam tuşuna basın ve kafanızı SAĞA çevirin"
    case plsSmie = "Tamam tuşuna basın ve gülümseyin"
}
