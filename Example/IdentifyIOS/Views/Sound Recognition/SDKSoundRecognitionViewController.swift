//
//  SDKSoundRecognitionViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 15.04.2021.
//

import UIKit
import Speech
import AVKit

protocol SoundRecognitionDelegate:class {
    func recognitionCompleted()
}


class SDKSoundRecognitionViewController: SDKBaseViewController {

    @IBOutlet var backView: UIView!
    
    @IBOutlet weak var btnStart: UIButton!
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR"))

    public private(set) var isRecording = false

    private var audioEngine: AVAudioEngine!
    private var inputNode: AVAudioInputNode!
    private var audioSession: AVAudioSession!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var delegate: SoundRecognitionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignConstants.soundScrBackgroundColor
        setupUI()
        btnStart.addTarget(self, action: #selector(startRecording), for: .touchDown)
        btnStart.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)
        addSkipModulesButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        audioSession = nil
    }
    
    func setupUI() {
        
        btnStart.setTitle(DesignConstants.soundScrBtnText, for: .normal)
        btnStart.setTitleColor(DesignConstants.soundScrBtnColor, for: .normal)
        btnStart.backgroundColor = DesignConstants.soundScrBtnBackColor
        btnStart.titleLabel?.font = DesignConstants.soundScrBtnFont
    }
    
    private func handleError(withMessage message: String) {
        // Present an alert.
        let ac = UIAlertController(title: "An error occured", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (resp) in
        }))
        present(ac, animated: true)

        btnStart.setTitle("Basılı tutun ve şehir ismini okuyun", for: .normal)
        btnStart.isEnabled = true
    }
    
    // MARK: - Speech recognition
    @objc func startRecording() {

        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            handleError(withMessage: "Speech recognizer not available.")
            return
        }


        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.shouldReportPartialResults = true

        recognizer.recognitionTask(with: recognitionRequest!) { (result, error) in
            guard error == nil else { self.handleError(withMessage: error!.localizedDescription); return }
            guard let result = result else { return }
            if result.isFinal {
                DispatchQueue.main.async {
                    self.updateUI(withResult: result)
                }
            }
        }

        audioEngine = AVAudioEngine()

        inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            // Activate the session.
            audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .spokenAudio, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            try audioEngine.start()
        } catch {
            handleError(withMessage: error.localizedDescription)
        }
    }

    private func updateUI(withResult result: SFSpeechRecognitionResult) {
        let resultText = result.bestTranscription.formattedString
        if resultText == "Berlin" {
            self.popupAlert(title: "Başarılı", message: "Kelime okuma başarılı", actionTitles: ["Tamam"], actions:[{ action1 in
                self.dismiss(animated: true) {
                    self.delegate?.recognitionCompleted()
                }
            }])
        } else {
            self.popupAlert(title: self.translate(text: .coreError), message: "Kelime okuma başarısız, söylenen kelime \(resultText)", actionTitles: [self.translate(text: .coreOk)], actions:[{ action1 in
            }])
        }
    }

    @objc func stopRecording() {
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        audioEngine.stop()
        inputNode.removeTap(onBus: 0) // Call after audio engine is stopped as it modifies the graph.

        try? audioSession.setActive(false)
        audioSession = nil
    }
    

    private func checkPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized: break
                default: self.handlePermissionFailed()
                }
            }
        }
    }

    private func handlePermissionFailed() {

        let ac = UIAlertController(title: "This app must have access to speech recognition to work.",
                                   message: "Please consider updating your settings.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Open settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        ac.addAction(UIAlertAction(title: "Close", style: .cancel))
        present(ac, animated: true)

        // Disable the record button.
        btnStart.isEnabled = false
        btnStart.setTitle("Speech recognition not available.", for: .normal)
    }

}

extension SDKSoundRecognitionViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.btnStart.isEnabled = true
        } else {
            self.btnStart.isEnabled = false
        }
    }
}
