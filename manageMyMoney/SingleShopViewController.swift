//
//  SingleShopViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import CoreData

class SingleShopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var numberOfTransLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var myTransactionsTable: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var shops:[Shop]?
    var transactions:[Transaction]?
    var selectedShop: Int?
    var totalAmount: Double?
    var numberOfTrans: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "transTableViewCell", bundle: nil)
        myTransactionsTable.register(nib, forCellReuseIdentifier: "transTableViewCell")
        myTransactionsTable.delegate = self
        myTransactionsTable.dataSource = self

        
        // Do any additional setup after loading the view.
        fetchShops()
        let shopName = shops![selectedShop!].name!
        fetchTransactions(shopName: shopName)
        if transactions!.count > 0 {
            totalAmountLabel.text = (transactions?[0].currency ?? "") + " \(totalAmount ?? 0.0)"
            numberOfTransLabel.text = "\(numberOfTrans ?? 0)"
        } else {
            totalAmountLabel.text = "$0.0"
            numberOfTransLabel.text = "0"
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
    
    func fetchTransactions(shopName: String) {
        do {
            let request = Transaction.fetchRequest() as NSFetchRequest<Transaction>
            
            let pred = NSPredicate(format: "shop.name CONTAINS %@", shopName)
            request.predicate = pred
            
            self.transactions = try context.fetch(request)
            
            totalAmount = 0.0
            numberOfTrans = 0
            for trans in transactions! {
                totalAmount! += trans.amount
                numberOfTrans! += 1
            }
            
            DispatchQueue.main.async {
                self.myTransactionsTable.reloadData()
            }
        }
        catch {
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transTableViewCell", for : indexPath) as! transTableViewCell
        
        let transaction = self.transactions![indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        cell.transAmount.text = "\(transaction.currency ?? "AED") \(transaction.amount)"
        cell.transDate.text = formatter.string(from: transaction.date!)
        cell.transImage.image = UIImage(data: transaction.receipt!)
        
        // the code that will be executed when user tap on the button
        // notice the capture block has [unowned self]
        // the 'self' is the viewcontroller
        cell.imageButtonAction = { [unowned self] in
            let alertController = UIAlertController(title: "Receipt", message: cell.transDate.text, preferredStyle: .alert)
            
            alertController.addImage(image: UIImage(data: transaction.receipt!)!)
            alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which transaction to remove
            let transToDelete = self.transactions![indexPath.row]
            
            //Remove the transaction
            self.context.delete(transToDelete)
            
            //Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            //Reload the data
            let shopName = self.shops![self.selectedShop!].name!
            self.fetchTransactions(shopName: shopName)
            if self.transactions!.count > 0 {
                self.totalAmountLabel.text = (self.transactions?[0].currency ?? "") + " \(self.totalAmount ?? 0.0)"
                self.numberOfTransLabel.text = "\(self.numberOfTrans ?? 0)"
            } else {
                self.totalAmountLabel.text = "$0.0"
                self.numberOfTransLabel.text = "0"
            }
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
