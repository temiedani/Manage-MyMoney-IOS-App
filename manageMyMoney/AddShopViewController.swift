//
//  AddShopViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AddShopViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet var addShopInstuctLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var shops:[Shop]?
    
    let locationManager = CLLocationManager()
    var sizeofRegion : Double = 1000
    let annotation = MKPointAnnotation()
    
    var selectedShop: Int?
    var shopSelected = false
    var editingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.mapType = .hybrid
        myMap.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(gestureRecognizer:)))
        myMap.addGestureRecognizer(gesture)
        
        checkLocationService()
        //Get items from Core Data
        fetchShops()
        if editingMode {
            let coordinate = CLLocationCoordinate2D(latitude: shops![selectedShop!].latitude, longitude: shops![selectedShop!].longitude)
            titleBar.title = "Editing  \(shops![selectedShop!].name ?? "")"
            addShopInstuctLabel.text = "Tap on the map to change shop location"
            alertPresentation(coordinate: coordinate)
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
    
    @objc func didTapMap(gestureRecognizer: UIGestureRecognizer) {
        
        let touchpointtemp = gestureRecognizer.location(in: self.myMap)
        let coordinate = self.myMap.convert(touchpointtemp, toCoordinateFrom: self.myMap)
        
        alertPresentation(coordinate: coordinate)
        
    }
    
    func alertPresentation (coordinate: CLLocationCoordinate2D) {
        
        annotation.coordinate = coordinate
        self.myMap.addAnnotation(annotation)
        
        let alert = UIAlertController(title: "New shop name", message: nil, preferredStyle: UIAlertController.Style.alert)
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter a name"
        }
        
        if (editingMode){
            alert.title = "Edit shop name"
            alert.textFields?[0].text = self.shops![self.selectedShop!].name
        }
    
           
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
            
            if let tempPlace = alert.textFields?[0].text {
                if (tempPlace == "") {
                    //tell user to try again
                    //self.myMap.removeAnnotation(self.annotation)
                    let invalidAlert = UIAlertController(title: "Empty shop name", message: "Please enter a valid shop name", preferredStyle: UIAlertController.Style.alert)
                    
                    let dismissAction = UIKit.UIAlertAction(title: "Dismiss", style:UIKit.UIAlertAction.Style.cancel) { (UIAlertAction) in print(1)
                    }
                    
                    invalidAlert.addAction(dismissAction)
                    
                    self.present(invalidAlert, animated: true, completion: nil)
                }
                else {
                    let place = tempPlace
                    
                    //Check if duplicate shop exists
                    var duplicateFlag = false
                    for shop in self.shops! {
                        
                        if (!self.editingMode && tempPlace == shop.name) {
                            duplicateFlag = true
                            break
                        }
                        
                        else if (self.editingMode && tempPlace == shop.name && tempPlace == self.shops![self.selectedShop!].name && coordinate.latitude == self.shops![self.selectedShop!].latitude && coordinate.longitude == self.shops![self.selectedShop!].longitude) {
                            duplicateFlag = true
                            break
                        }
                    }
                    

                    if duplicateFlag {
                        let invalidAlert = UIAlertController(title: "Place name already exists", message: "No changes made", preferredStyle: UIAlertController.Style.alert)
                        
                        let dismissAction = UIKit.UIAlertAction(title: "Dismiss", style:UIKit.UIAlertAction.Style.cancel) { (UIAlertAction) in print(1)
                        }
                        
                        
                        invalidAlert.addAction(dismissAction)
                        
                        self.present(invalidAlert, animated: true, completion: nil)
                        return
                    }
                    
                    switch self.editingMode {
                    case true:
                        self.shops![self.selectedShop!].name = tempPlace
                        self.shops![self.selectedShop!].latitude = coordinate.latitude
                        self.shops![self.selectedShop!].longitude = coordinate.longitude
                        
                    default:
                        //Create a shop object
                        let newShop = Shop(context: self.context)
                        newShop.name = tempPlace
                        newShop.latitude = coordinate.latitude
                        newShop.longitude = coordinate.longitude
                    }
                                        
                    //Save the data
                    do {
                        try self.context.save()
                    }
                    catch {
                        
                    }
                    
                    //Re-fetch the data
                    self.fetchShops()
                    
                    //unwindListOfShops
                    self.performSegue(withIdentifier: "unwindShopsList", sender: self)
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in //self.myMap.removeAnnotation(self.annotation)
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setUpLocationManager() {
        
        locationManager.delegate  = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationService(){
        
        if CLLocationManager.locationServicesEnabled()
        {
            
            setUpLocationManager()
            checkAuthorization()
        }
        
        else {
            print ("not enabled")
        }
    }
    
    func spanOnUserLocation(){
        
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location , latitudinalMeters: sizeofRegion, longitudinalMeters: sizeofRegion )
            myMap.setRegion(region, animated: true)
        }
    }
    
    func checkAuthorization(){
        switch CLLocationManager.authorizationStatus()
        {
        case .authorizedWhenInUse : //you have already allowed the applicstion to use the service while in use
            myMap.showsUserLocation = true
            spanOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        case .notDetermined: // first time
            
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted: // there are some restrictions omn the use of the service like parental control
            break
        case .authorizedAlways: // even when the application  in the background ....
            break
        case .denied : // show alert instrcuting them how to turn on the permissions
            break
        default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: sizeofRegion, longitudinalMeters: sizeofRegion)
        myMap.setRegion(region, animated: true)
        
    }
    
}
