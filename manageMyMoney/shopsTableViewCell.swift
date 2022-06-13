//
//  shopsTableViewCell.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit

class shopsTableViewCell: UITableViewCell {

    @IBOutlet var myShopName: UILabel!
    @IBOutlet var myShopImage: UIImageView!
    @IBOutlet var totalAmount: UILabel!
    @IBOutlet var lastAmount: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageButton: UIButton!
    
    var imageButtonAction : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
