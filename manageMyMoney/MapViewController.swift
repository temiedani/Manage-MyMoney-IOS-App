//
//  mapViewController.swift
//  manageMyMoney
//
//  Created by Temesgen Daniel on 03/01/2021.
//  Copyright © 2021 kustar. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var passedLatitude: Double = 0
    var passedLongitude: Double = 0
    
    let locationManager = CLLocationManager()
    let pinImage = UIImage(named: "pinImage")
    
    @IBOutlet weak var myMap: MKMapView!
    
    @IBOutlet weak var titleBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        spanOnShopLocation()
    }
    
    func spanOnShopLocation(){
        
        let location = CLLocationCoordinate2D(latitude: passedLatitude, longitude: passedLongitude)
        let regionSize: Double = 500
        
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionSize, longitudinalMeters: regionSize)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(passedLatitude, passedLongitude)
        myMap.addAnnotation(annotation)
        myMap.setRegion(region, animated: true)
    }
    
    func longpress(gestureRecognizer: UIGestureRecognizer) {
    
    let touchpointtemp = gestureRecognizer.location(in: self.myMap)
    
        let alert = UIAlertController(title: "New Place", message: "Enter a name", preferredStyle: UIAlertController.Style.alert)
    
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Name"
        }
    
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
    
            if let tempPlace = alert.textFields?[0].text {
                let place = tempPlace
                let touchpoint = touchpointtemp
                let coordinate = self.myMap.convert(touchpoint, toCoordinateFrom: self.myMap)
    
                print(coordinate)
                let annotation = MKPointAnnotation()
                let latitude = coordinate.latitude
                let longitude = coordinate.longitude
    
                annotation.title = place
                annotation.subtitle = "Lat " + (String(format: "%.2f", latitude) + " Lon " + String(format: "%.2f", longitude))
                annotation.coordinate = coordinate
                self.myMap.addAnnotation(annotation)
            }
    
    
        }
    
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (UIAlertAction) in
        }
    
        alert.addAction(okAction)
        alert.addAction(cancelAction)
    
        present(alert, animated: true, completion: nil)
    
    }
}


