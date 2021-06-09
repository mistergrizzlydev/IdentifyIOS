//
//  SmileViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 9.02.2021.
//

import UIKit
import SceneKit
import ARKit
import IdentifyIOS

protocol SmileDelegate:class {
    func smileCompleted()
}

class SmileViewController: SDKBaseViewController {

    @IBOutlet var myCam: ARSCNView!
    var manager: IdentifyManager?
    let configuration = ARFaceTrackingConfiguration()
    @IBOutlet weak var smileInfoLabel: UILabel!
    @IBOutlet weak var smileDescriptionLabel: UILabel!
    weak var delegate: SmileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCam.delegate = self
        translate()
        if ARFaceTrackingConfiguration.isSupported {
            myCam.session.run(configuration)
        } else {
            self.dismiss(animated: true)
        }
        addSkipModulesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myCam.session.pause()
    }
    
    func translate() {
        smileInfoLabel.text = self.translate(text: .humanSmile)
        smileDescriptionLabel.text = self.translate(text: .humanSmileDescription)
    }
}
extension SmileViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: myCam.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
            faceGeometry.update(from: faceAnchor.geometry)
            expression(anchor: faceAnchor)
        }
    }
    
    func expression(anchor: ARFaceAnchor) {
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.manager?.sendLiveStatus()
            myCam.session.pause()
            DispatchQueue.main.async {
                self.delegate?.smileCompleted()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
