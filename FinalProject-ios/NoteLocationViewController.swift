//
//  NoteLocationViewController.swift
//  FinalProject-ios
//
//  Created by Simran Chakkal on 2020-01-27.
//  Copyright © 2020 simran. All rights reserved.
//

import UIKit
import MapKit
import  CoreLocation
import CoreData

class NoteLocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var latitude:Double = 48
    var longitude:Double = -78
    
    var locationmanager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 300
    
    @IBOutlet var myMapView: MKMapView!
    
    override func viewDidLoad() {
       // Do any additional setup after loading the view.
        
        
        locationmanager.delegate = self
        locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
        
        myMapView.showsUserLocation = true
        print("user latitude = \(latitude)")
        print("user longitude = \(longitude)")
        let noteLocation = CLLocation(latitude: latitude, longitude: longitude)
          super.viewDidLoad(); self.navigationController!.setNavigationBarHidden(false, animated: true)
        self.title = "Note Location"
        
        let coordinateRegion = MKCoordinateRegion(center: noteLocation.coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        self.myMapView.setRegion(coordinateRegion, animated: true)
        
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(noteLocation.coordinate.latitude, noteLocation.coordinate.longitude);
        myAnnotation.title = "Note Location"
        myAnnotation.subtitle = "\(latitude),\(longitude)"
        self.myMapView.addAnnotation(myAnnotation)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func sgmMapview(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
              {
              case 0:
                  myMapView.mapType = MKMapType.standard
              case 1:
                  myMapView.mapType = MKMapType.satellite
              case 2:
                  myMapView.mapType = MKMapType.hybrid
                  
              default:
                  myMapView.mapType = MKMapType.standard
              }
    }
    
}
