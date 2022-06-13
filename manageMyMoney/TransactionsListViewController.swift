//
//  TransactionsListViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import CoreData

class TransactionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTransTable: UITableView!
    @IBOutlet var viewShopButton: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var shops:[Shop]?
    var transactions:[Transaction]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "transTableViewCell", bundle: nil)
        myTransTable.register(nib, forCellReuseIdentifier: "transTableViewCell")
        myTransTable.delegate = self
        myTransTable.dataSource = self

        //Get items from Core Data
        fetchTransactions()
        myTransTable.rowHeight = UITableView.automaticDimension
        myTransTable.estimatedRowHeight = 400
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTransactions()
        myTransTable.rowHeight = UITableView.automaticDimension
        myTransTable.estimatedRowHeight = 400

    }
    
    func fetchTransactions() {
        //Fetch transactions from Core Data
        do {
            
            let request = Transaction.fetchRequest() as NSFetchRequest<Transaction>
            
            self.transactions = try context.fetch(request)
        }
        catch {
            
        }
        
        
        do {
            let request = Transaction.fetchRequest() as NSFetchRequest<Transaction>
            
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            
            self.transactions = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.myTransTable.reloadData()
            }
            
        }
        catch {
            
        }        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactions?.count ?? 0 > 5 {
            return 5
        }
        return self.transactions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "transTableViewCell", for : indexPath) as! transTableViewCell
        
        let transaction = self.transactions![indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        cell.transAmount.text = (transaction.currency ?? "AED") + " \(transaction.amount)"
        cell.transShop.text = " @" + (transaction.shop?.name)!
        cell.transDate.text = formatter.string(from: transaction.date!)
        cell.transImage.image = UIImage(data: transaction.receipt!)
        
        // the code that will be executed when user tap on the button
        // notice the capture block has [unowned self]
        // the 'self' is the viewcontroller
        cell.imageButtonAction = { [unowned self] in
            let alertController = UIAlertController(title: cell.transDate.text, message: transaction.details! + cell.transShop.text!, preferredStyle: .alert)
            
            alertController.addImage(image: UIImage(data: transaction.receipt!)!)
            alertController.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which shop to remove
            let transToDelete = self.transactions![indexPath.row]
            
            //Remove the shop and its transactions
            self.context.delete(transToDelete)
            
            //Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            //Reload the data
            self.fetchTransactions()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
}
