//
//  transTableViewCell.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit

class transTableViewCell: UITableViewCell {

    @IBOutlet var transAmount: UILabel!
    @IBOutlet var transShop: UILabel!
    @IBOutlet var transDate: UILabel!
    @IBOutlet var transImage: UIImageView!
    
    @IBOutlet weak var imageButton: UIButton!
    
    var imageButtonAction : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transShop.text = ""
        
        self.imageButton.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func imageButtonTapped(_ sender: UIButton){
      // if the closure is defined (not nil)
      // then execute the code inside the imageButtonAction closure
      imageButtonAction?()
    }
    
}
