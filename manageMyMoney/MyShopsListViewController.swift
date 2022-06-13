//
//  myShopsListViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation

class myShopsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myShopsTable: UITableView!
    
    let locationManager = CLLocationManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var shops:[Shop]?
    var transactions:[Transaction]?
    
    var selectedShop: Int?
    var willEdit: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "shopsTableViewCell", bundle: nil)
        myShopsTable.register(nib, forCellReuseIdentifier: "shopsTableViewCell")
        myShopsTable.delegate = self
        myShopsTable.dataSource = self
        
        willEdit = false

        //Get items from Core Data
        fetchShops()
        fetchTransactions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        willEdit = false
        
        //Get items from Core Data
        fetchShops()
        fetchTransactions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMapSegue" {
            let mapsVC = segue.destination as! mapViewController
            mapsVC.passedLatitude = self.shops![selectedShop!].latitude
            mapsVC.passedLongitude = self.shops![selectedShop!].longitude
            mapsVC.titleBar.title = shops![selectedShop!].name
            
        } else if segue.identifier == "toAddShop" {
            let addVC = segue.destination as! AddShopViewController
            if willEdit! {
                addVC.editingMode = true
                addVC.selectedShop = selectedShop
            }
            
        } else if segue.identifier == "toSingleShop" {
            let singleShopVC = segue.destination as! SingleShopViewController
            singleShopVC.titleBar.title = shops![selectedShop!].name
            singleShopVC.selectedShop = selectedShop
        }
        
    }
    
    func fetchShops() {
        //Fetch shops from Core Data
        do {
            let request = Shop.fetchRequest() as NSFetchRequest<Shop>
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            
            self.shops = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.myShopsTable.reloadData()
            }
        }
        catch {
            
        }

    }

    func fetchTransactions() {
        //Fetch transactions from Core Data
        do {
            
            let request = Transaction.fetchRequest() as NSFetchRequest<Transaction>
            
            self.transactions = try context.fetch(request)
            
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
            
            let sort = NSSortDescriptor(key: "date", ascending: false)
            request.sortDescriptors = [sort]
            self.transactions = try context.fetch(request)
        }
        catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "shopsTableViewCell", for : indexPath) as! shopsTableViewCell
        
        let shop = self.shops![indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        fetchTransactions(shopName: shop.name!)
        var totalAmount = 0.0
        for trans in transactions! {
            totalAmount += trans.amount
        }
        
        cell.myShopName.text = shop.name
        if transactions!.count > 0 {
            cell.lastAmount.text = "Last: " + (transactions?[0].currency ?? "$") + "\(transactions![0].amount) - " + formatter.string(from: transactions![0].date!)
            cell.totalAmount.text = "Total: " + (transactions?[0].currency ?? "$") + "\(totalAmount)"
        } else {
            cell.lastAmount.text = "No records."
            cell.totalAmount.text = "Total: $\(totalAmount)"
        }
        
        cell.myShopImage.backgroundColor = .lightGray
                
        if cell.myShopImage.image == nil {
            loadMapPreview(latitude: shop.latitude, longitude: shop.longitude, imageView: cell.myShopImage, indicator: cell.activityIndicator)
        }
        
        // the code that will be executed when user tap on the button
        // notice the capture block has [unowned self]
        // the 'self' is the viewcontroller
        cell.imageButtonAction = { [unowned self] in
            self.selectedShop = indexPath.row
            self.performSegue(withIdentifier: "toMapSegue", sender: self)
        }
        
        return cell
    }
    
    private func loadMapPreview(latitude: Double, longitude: Double, imageView: UIImageView, indicator: UIActivityIndicatorView) {
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let distanceInMeters: Double = 1000
        
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(center: location, latitudinalMeters: distanceInMeters, longitudinalMeters: distanceInMeters)
        
        options.size = imageView.frame.size
        
        
        let bgQueue = DispatchQueue.global(qos: .background)
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(with: bgQueue, completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                return
            }
            
            if let snapShotImage = snapshot?.image {
                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)
                snapShotImage.draw(at: CGPoint.zero)
                
                
                let mapImage = UIGraphicsGetImageFromCurrentImageContext()
                
                DispatchQueue.main.async {
                    imageView.image = mapImage
                    indicator.stopAnimating()
                    indicator.isHidden = true
                }
                UIGraphicsEndImageContext()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedShop = indexPath.row
        performSegue(withIdentifier: "toSingleShop", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which shop to remove
            let shopToDelete = self.shops![indexPath.row]
            
            //Transactions to delete
            self.fetchTransactions(shopName: shopToDelete.name!)
            
            //Remove the shop and its transactions
            self.context.delete(shopToDelete)
            for trans in self.transactions! {
                self.context.delete(trans)
            }
            
            //Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            //Reload the data
            self.fetchShops()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Edit") { (action, view, completionHandler) in
            
            //Which shop to edit
            self.selectedShop = indexPath.row
            
            //TODO: Edit the shop
            self.willEdit = true
            self.performSegue(withIdentifier: "toAddShop", sender: self)
                        
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
