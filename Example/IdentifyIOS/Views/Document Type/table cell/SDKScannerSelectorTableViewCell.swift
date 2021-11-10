//
//  SDKScannerSelectorTableViewCell.swift
//  Kimlik
//
//  Created by Emir Beytekin on 7.10.2021.
//

import UIKit

class SDKScannerSelectorTableViewCell: UITableViewCell {

    @IBOutlet weak var sectionImg: UIImageView!
    @IBOutlet weak var sectionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
