//
//  WelcomeWaitViewController.swift
//  Kimlik
//
//  Created by MacBookPro on 24.03.2021.
//

import UIKit
import IdentifyIOS

class SDKModulesListViewController: SDKBaseViewController, PopUpProtocol {
    
    var manager: IdentifyManager!
    @IBOutlet weak var tableView: UITableView!
    var list = [Modules]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.allModules()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isEditing = true
        self.list = manager.identfiyModules
    }
    
    @IBAction func nextAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func handlePopUpAction(action: Bool) {
        self.dismiss(animated: true) {
        }
    }
    
}
extension SDKModulesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.textLabel?.text = list[indexPath.row].mName
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.reorderControlImageView?.tint(color: UIColor.black)
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            list.remove(at: indexPath.row)
            manager.identfiyModules.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            manager.identfiyModules.removeAll()
            manager.identfiyModules = list
            debugPrint(manager.identfiyModules)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt indexPath: IndexPath, to: IndexPath) {
        let itemToMove = list[indexPath.row]
        list.remove(at: indexPath.row)
        list.insert(itemToMove, at: to.row)
        manager.identfiyModules.removeAll()
        manager.identfiyModules = list
        debugPrint(manager.identfiyModules)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}

extension UITableViewCell {

    var reorderControlImageView: UIImageView? {
        let reorderControl = self.subviews.first { view -> Bool in
            view.classForCoder.description() == "UITableViewCellReorderControl"
        }
        return reorderControl?.subviews.first { view -> Bool in
            view is UIImageView
        } as? UIImageView
    }
}

extension UIImageView {

    func tint(color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
}
