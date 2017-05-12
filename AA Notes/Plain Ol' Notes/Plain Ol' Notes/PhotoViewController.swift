//
//  PhotoViewController.swift
//  AA Notes
//
//  Created by AA Group on 2017-04-05.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//
// description: show full-size image
//              button(location of image)
//              delete image

import UIKit
import Photos
import CoreLocation
import MapKit
import CoreData

class PhotoViewController: UIViewController, UIScrollViewDelegate {
    
    var arrayImages: Array<UIImage> = []
    var assetCollection: PHAssetCollection!
    var photosAsset: PHFetchResult<PHAsset>!
    var index: Int = 0
    var region: MKCoordinateRegion? = nil
    var getImageIdForDeleting: String = ""
    var deleteIndexFromPhotoView: Int? = nil

    @IBAction func btnCancel(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindCancelFromDetailView", sender: self)
    }
    @IBAction func btnGeolocation(_ sender: UIButton) {
    }
    @IBAction func btnTrash(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.performSegue(withIdentifier: "unwindFromDetailView", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) in
            //Do not delete photo
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //save photo index and ID to be used when delete image
        self.deleteIndexFromPhotoView = self.index
        
        // Do any additional setup after loading the view.
        ScrollView.minimumZoomScale = 1.0
        ScrollView.maximumZoomScale = 6.0
        ScrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hidesBarsOnTap = false    //!!Added Optional Chaining
        self.displayPhoto()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewMap") {
            let mapView: MapViewController = segue.destination as! MapViewController
            mapView.region = self.region
            mapView.imageID = self.getImageIdForDeleting
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func displayPhoto(){
        // Set targetSize of image to iPhone screen size
        let screenSize: CGSize = UIScreen.main.bounds.size
        
        self.imageView.image = arrayImages[self.index]
        self.imageView.image?.size.equalTo(screenSize)
    }
    
    func getImageInfo(imageID: String) -> String{
        let getImageIdForDeleting: String = imageID
        return getImageIdForDeleting
    }
    
}
