//
//  AddTransactionViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import CoreData
import DropDown

class AddTransactionViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var amountTextField: UITextField!
    @IBOutlet var currencyTextField: UITextField!
    @IBOutlet var detailsTextField: UITextField!
    @IBOutlet var noImageLabel: UILabel!
    @IBOutlet var addImageButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var shops:[Shop]?
    var selectedShop: Int?
    var shopSelected = false
    
    var editingMode = false
    var selectedTrans: Int?

    var menu: DropDown = {
        let menu = DropDown()
        return menu
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchShops()
        
        menu = {
            let menu = DropDown()
            var shopNames: [String] = []
            
            for shop in shops! {
                shopNames.append(shop.name!)
            }
            
            menu.dataSource = shopNames
            return menu
        }()
    
        shopNameWithIcon(labelName: "Choose Shop")
        
        //Currently not allowing future date scrolling
        datePicker.maximumDate = NSDate() as Date
        
        amountTextField.placeholder = "Enter amount"
        amountTextField.keyboardType = UIKeyboardType.decimalPad
        
        currencyTextField.placeholder = "Currency"
        currencyTextField.text = "$"
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
        
        imageView.image = UIImage(named: "no-receipt-icn")
        
        menu.anchorView = shopNameLabel
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapShops))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        shopNameLabel.addGestureRecognizer(gesture)
        
        let imageGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageGesture.numberOfTapsRequired = 1
        imageGesture.numberOfTouchesRequired = 1
        noImageLabel.addGestureRecognizer(imageGesture)
        
        menu.selectionAction = {
            index, title in self.shopNameWithIcon(labelName: title)
            //self.shopNameLabel.backgroundColor = .lightText
            self.shopSelected = true
            self.selectedShop = index
        }
    }
    
    func fetchShops() {
        //Fetch shops from Core Data
        do {
            let request = Shop.fetchRequest() as NSFetchRequest<Shop>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.shops = try context.fetch(request)

        }
        catch {
            
        }
    }
    
    @IBAction func didTapShops() {
        menu.show()
    }
    
    @IBAction func didTapImage() {
        
        let alertController = UIAlertController(title: "Receipt", message: "", preferredStyle: .alert)
        
        alertController.addImage(image: imageView.image!)
        alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    
    
    @IBAction func didTapReceiptButton() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func didTapDone() {
        //TODO Get the data, save to db
        
        //TODO Confirmation alert box
        //Dismiss if details are sufficient(shop,date,amount)
        if (shopSelected && !(amountTextField.text!.isEmpty) && !(currencyTextField.text!.isEmpty)) {
            
            let alertController = UIAlertController(title: "Success", message: "Transaction added successfully.", preferredStyle: .alert)
            
            
            //Create a transaction
            let transaction = Transaction(context: context)
            
            //Add transaction to shop
            transaction.amount = Double(amountTextField.text!)!
            transaction.currency = currencyTextField.text
            transaction.date = datePicker.date
            transaction.details = detailsTextField.text ?? ""
            
            if let imageData = imageView.image!.pngData() {
                transaction.receipt = imageData
            }
            transaction.shop = shops![selectedShop!]
            //Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            //Go back to list of transactions
            let defaultAction = UIAlertAction(title: "Dismiss", style: .default) { (action:UIAlertAction) in
                self.performSegue(withIdentifier: "unwindTranList", sender: self)}
            
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
            
        else {
            let alertController = UIAlertController(title: "Incomplete", message: "Please fill all the necessary fields.", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action:UIAlertAction) in
                
            }
            
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func saveTranaction() {
        
    }
    
    func shopNameWithIcon (labelName: String) {
        let imageIcon = NSTextAttachment()
        imageIcon.image = UIImage(systemName: "chevron.down.square.fill")
        let imageOffsetY: CGFloat = -5.0
        imageIcon.bounds = CGRect(x: 5.0, y: imageOffsetY, width: 20, height: 20)
        
        let completeText = NSMutableAttributedString(string: "")
        
        let textBeforeIcon = NSAttributedString(string: labelName)
        completeText.append(textBeforeIcon)
        
        let attachmentString = NSAttributedString(attachment: imageIcon)
        completeText.append(attachmentString)
        
        self.shopNameLabel.textAlignment = .center
        self.shopNameLabel.attributedText = completeText
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
            noImageLabel.text = ""
            addImageButton.setTitle("Change receipt photo", for: UIControl.State.normal)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
