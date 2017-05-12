//
//  MapViewController.swift
//  AA Notes
//
//  Created by AA Group on 2017-04-05.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//
// description: Location of image

import UIKit
import CoreLocation
import MapKit
import CoreData

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var region: MKCoordinateRegion? = nil
    var imageID: String = ""
    var location1: Float = 0
    var location2: Float = 0
    var pictureAdress: String = ""

    @IBOutlet weak var map: MKMapView!
    
    let manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<Image> = Image.fetchRequest()
        do {
            let fetchedImage = try context.fetch(fetchRequest)
            for result in fetchedImage as [Image] {
                if result.image_id == imageID {
                    self.location1 = result.locationV1
                    self.location2 = result.locationV2
                }
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(CLLocationDegrees(self.location1), CLLocationDegrees(self.location2))
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        
        let locationAddress = CLLocation(latitude: CLLocationDegrees(self.location1), longitude: CLLocationDegrees(self.location2))
        
        self.addAnnotationsOnMap(locationToPoint: locationAddress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false    //!!Added Optional Chaining
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //function to add annotation to map view
    func addAnnotationsOnMap(locationToPoint : CLLocation){
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationToPoint.coordinate
        let geoCoder = CLGeocoder ()
        geoCoder.reverseGeocodeLocation(locationToPoint, completionHandler: { (placemarks, error) -> Void in
            if let placemarks = placemarks, placemarks.count > 0 {
                let placemark = placemarks[0]
                var addressDictionary = placemark.addressDictionary;
                annotation.title = addressDictionary?["Name"] as? String
                annotation.subtitle = addressDictionary?["Thoroughfare"] as? String
                self.map.addAnnotation(annotation)
            }
        })
    }
    
}
