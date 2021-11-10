//
//  SDKScannerSelectorViewController.swift
//  Kimlik
//
//  Created by Emir Beytekin on 7.10.2021.
//

import UIKit

class SDKScannerSelectorViewController: SDKBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var titles = [String]()
    var imgArray = [UIImage]()
    var delegate: DismissIDDelegate?
    var cardType: CardType? = .idCard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appendTitles()
        tableView.register(UINib(nibName: "SDKScannerSelectorTableViewCell", bundle: nil), forCellReuseIdentifier: "SDKScannerSelectorTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func appendTitles() {
        titles.append(self.translate(text: .newIdCard))
        titles.append(self.translate(text: .passport))
        titles.append(self.translate(text: .otherCards))
        imgArray.append(#imageLiteral(resourceName: "idCard"))
        imgArray.append(#imageLiteral(resourceName: "passport"))
        imgArray.append(#imageLiteral(resourceName: "travel"))
        tableView.reloadData()
    }

}
extension SDKScannerSelectorViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.white
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = self.translate(text: .scanType)
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (UIScreen.main.bounds.height - 82) / CGFloat(titles.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SDKScannerSelectorTableViewCell", for: indexPath) as! SDKScannerSelectorTableViewCell
        cell.contentView.backgroundColor = .clear
        cell.sectionName.text = titles[indexPath.row]
        cell.sectionImg.image = imgArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nfcAvailable {
            switch indexPath.row {
            case 0:
                cardType = .idCard
            case 1:
                cardType = .passport
            case 2:
                cardType = .oldSchool
                manager.sendNFCStatus("Other Cards")
            default:
                return
            }
        } else {
            cardType = .oldSchool
        }
        
        self.dismiss(animated: true, completion: {
            self.delegate?.updateSelectedType(cardType: self.cardType ?? .idCard)
        })
    }
    
    
}
