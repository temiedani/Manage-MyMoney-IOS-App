//
//  DDCell.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.

import UIKit
import DropDown

class DDCell: DropDownCell {

    @IBOutlet var myImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
