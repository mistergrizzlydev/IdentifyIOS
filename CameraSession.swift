//
//  CameraSession.swift
//  SimpleWebRTC
//
//  Created by tkmngch on 2019/02/08.
//  Copyright © 2019 tkmngch. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol CameraSessionDelegate {
    func didOutput(_ sampleBuffer: CMSampleBuffer)
}
class CameraSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private var session: AVCaptureSession?
    private var output: AVCaptureVideoDataOutput?
    private var device: AVCaptureDevice?
    weak var delegate: CameraSessionDelegate?
    
    override init() {
        super.init()
    }
    
    func setupSession(isFront: Bool = true){
        self.session = AVCaptureSession()
        if isFront {
            self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        } else {
            self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        guard (try? AVCaptureDeviceInput(device: device!)) != nil else {
            // print("Caught exception!")
            return
        }
        self.output = AVCaptureVideoDataOutput()
        let queue: DispatchQueue = DispatchQueue(label: "videodata", attributes: .concurrent)
        self.output?.setSampleBufferDelegate(self, queue: queue)
        self.output?.alwaysDiscardsLateVideoFrames = false
        self.output?.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] as [String : Any]
        
        self.session?.addOutput(self.output!)
        
        self.session?.sessionPreset = AVCaptureSession.Preset.inputPriority
        self.session?.usesApplicationAudioSession = false
        
        self.session?.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.delegate?.didOutput(sampleBuffer)
    }
}
