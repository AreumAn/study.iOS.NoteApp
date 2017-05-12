//
//  DetailViewController.swift
//  AA Notes
//
//  Created by AA Group on 2017-04-05.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//
// description: write new note or edit note
//              camera button

import UIKit
import CoreData
import Photos
import CoreLocation
import MapKit

let reuseIdentifier: String = "PhotoCell"

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var text: String = ""
    var masterView: ViewController!
    var selectRow: Int? = nil
    var tValue: Int? = nil
    
    var albumFound: Bool = false
    var assetCollection: PHAssetCollection = PHAssetCollection()
    var photosAsset: PHFetchResult<PHAsset>!
    var assetThumbnailSize: CGSize!
    
    var arrayImages: Array<UIImage> = []
    var arrayImageId: Array<String> = []
    var deleteIndexFromPhotoView: Int?
    var getImageIdForDeleting: String = ""
    
    let manager = CLLocationManager()
    var region: MKCoordinateRegion? = nil
    
    var locationVersion1: Float = 0
    var locationVersion2: Float = 0
    
    var fuck: Array<UIImage> = []
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var noPhotosLabel: UILabel!
    
    @IBAction func btnCamera(_ sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            //load the camera interface
            let picker : UIImagePickerController = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.delegate = self
            picker.allowsEditing = false
            self.present(picker, animated: true, completion: nil)
        } else {
            //no camera available
            let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func btnAlbum(_ sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.delegate = self
        picker.allowsEditing = false
        self.present(picker, animated: true, completion: nil)
    }
    
    func setIndexImg(indexImg: Int) {
        // This is executed before come back to the main view and for that reason doesnt show the index
        print("vai desgrama, imprime essa linha aqui na DetailsView: \(indexImg)")
        self.deleteIndexFromPhotoView = indexImg
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.text = text
        
        // Save button
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DetailViewController.addNoteDetails))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        //get the current location of the user in case of upload or update the images of the note
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        //hide keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //fetch the photos from collection
        self.navigationController?.hidesBarsOnTap = false   //!! Use optional chaining
        self.photosAsset = PHAsset.fetchAssets(in: self.assetCollection, options: nil)
        
        if self.deleteIndexFromPhotoView != nil {
            //delete from array
            self.arrayImages.remove(at: self.deleteIndexFromPhotoView!)
            self.arrayImageId.remove(at: self.deleteIndexFromPhotoView!)
            
            //delete from core data
            deleteImgFromCoreData(imageID: self.getImageIdForDeleting)
        }
    
        if(self.arrayImages.count == 0){
            self.noPhotosLabel.isHidden = false
        } else {
            self.noPhotosLabel.isHidden = true
        }
        
        self.collectionView.reloadData()
        
    }
    
    func setText(t:String, r:Int) {
        // t: text
        // r : select row
        // tValue = 1 : existed data
        // tValue = 0 : new data
        
        // check it is update data or not
        
        // get select row
        selectRow = r
        text = t
        
        
        if t != "" {
            tValue = 1
            setImage()
        } else {
            tValue = 0
        }
        
        
        if isViewLoaded {
            textView.text = t
        }
        
    }
    
    func setImage() {
        
        // set Image from core data
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let fetchRequestImage: NSFetchRequest<Image> = Image.fetchRequest()
        var keynote_id:String = ""
        
        do {
            let fetchedNote = try context.fetch(fetchRequest)
            for keyResult in fetchedNote as [Note] {
                if keyResult.details == text {
                    keynote_id = keyResult.note_id!
                }
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        do {
            let fetchedImage = try context.fetch(fetchRequestImage)
            for result in fetchedImage as [Image] {
                if result.note_id == keynote_id {
                    self.arrayImages.append(UIImage(data:result.image! as Data, scale:0.5)!)
                    self.arrayImageId.append(result.image_id!)
                }
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func addNoteDetails() {
        // r : select row
        // tValue = 1 : existed data
        // tValue = 0 : new data
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let fetchRequestImage: NSFetchRequest<Image> = Image.fetchRequest()
        
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyymmddhhmmss"
        
        do {
            var fetchedNote = try context.fetch(fetchRequest)
            
            // check it is update data or new
            if (tValue == 0) {
                //new
                if textView.text != "" {
                    let note = Note(context: context)
                    note.details = textView.text
                    note.created = NSDate()
                    note.note_id = formatter.string(from: date as Date)
                    
                    for result in arrayImages {
                        let image = Image(context: context)
                        var indextTemp = 0
                        image.note_id = note.note_id
                        image.locationV1 = locationVersion1
                        image.locationV2 = locationVersion2
                        image.image_id = ("\(formatter.string(from: date as Date))\(String(Int(arc4random_uniform(UInt32(100)))))")
                        image.image = UIImageJPEGRepresentation(result, 0.5) as NSData?
                        indextTemp += 1
                    }
                    // if text view is empty : not store
                }
            } else if (tValue == 1) {
                // update
                if textView.text != "" {
                    
                    let note = fetchedNote[selectRow!]
                    
                    var keynoteDel_id:String = ""
                    
                    do {
                        let fetchedNote = try context.fetch(fetchRequest)
                        
                        for keyResult in fetchedNote as [Note] {
                            if keyResult.details == text {
                                keynoteDel_id = keyResult.note_id!
                                keyResult.details = textView.text
                            }
                        }
                        
                    } catch {
                        fatalError("Failed to fetch person: \(error)")
                    }
                    
                    //deleteImageFromNote(noteID: keynoteDel_id)
                    
                    do {
                        let fetchedImage = try context.fetch(fetchRequestImage)
                        
                        // new image insert into coredata Image entity
                        if arrayImages.count != 0 {
                            for (row,imageFindNew) in arrayImageId.enumerated() {
                                if imageFindNew == "new" {
                                    let image = Image(context: context)
                                    image.note_id = keynoteDel_id
                                    //image.locaton = self.region as? NSData
                                    image.locationV1 = locationVersion1
                                    image.locationV2 = locationVersion2
                                    image.image_id = ("\(formatter.string(from: date as Date))\(String(Int(arc4random_uniform(UInt32(100)))))")
                                    image.image = UIImageJPEGRepresentation(arrayImages[row], 0.5) as NSData?
                                }
                            }
                        }
                        
                        
                    } catch {
                        fatalError("Failed to fetch person: \(error)")
                    }
                    
                }
                
            }
            
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        ad.saveContext()
        
        arrayImages.removeAll()
        
        // go to the first page
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func deleteImgFromCoreData(imageID: String) {
        //Delete Photo
        let fetchRequestImage: NSFetchRequest<Image> = Image.fetchRequest()
        do {
            let fetchedImage = try context.fetch(fetchRequestImage)
            for result in fetchedImage as [Image] {
                if result.image_id == imageID {
                    context.delete(result)
                    ad.saveContext()
                }
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    func deleteImageFromNote(noteID: String) {
        let fetchRequestImageTest: NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "note_id = '\(noteID)'", "")
        fetchRequestImageTest.predicate = predicate
        let deleteImgRequest = NSBatchDeleteRequest(fetchRequest: fetchRequestImageTest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteImgRequest)
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        masterView.newRowText = textView.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewLargePhoto"){
            if let controller: PhotoViewController = segue.destination as? PhotoViewController {
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = self.collectionView.indexPath(for: cell) {
                        controller.index = indexPath.item
                        controller.arrayImages = arrayImages
                        controller.photosAsset = self.photosAsset
                        controller.assetCollection = self.assetCollection
                        controller.region = self.region
                        controller.getImageIdForDeleting = PhotoViewController().getImageInfo(imageID: arrayImageId[indexPath.item])
                        controller.deleteIndexFromPhotoView = self.deleteIndexFromPhotoView
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToDetailView(_ sender: UIStoryboardSegue) {
        if (sender.identifier == "unwindFromDetailView") {
            if let sourceViewController = sender.source as? PhotoViewController {
                self.getImageIdForDeleting = sourceViewController.getImageIdForDeleting
                self.deleteIndexFromPhotoView = sourceViewController.deleteIndexFromPhotoView
            }
        }
        if (sender.identifier == "unwindCancelFromDetailView") {
            if let sourceViewController = sender.source as? PhotoViewController {
                self.getImageIdForDeleting = ""
                self.deleteIndexFromPhotoView = nil
            }
        }
    }
    
    //Collection View Code ----------
    
    //UICollectionViewDataSource Methods (Remove the "!" on variables in the function prototype)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.arrayImages.count > 0 {
            return self.arrayImages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell: PhotoCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let image = arrayImages[indexPath.row]
        cell.imgView.image = image
        
        return cell
    }
    
    //UICollectionViewDelegateFlowLayout methods
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 1
    }
    
    //UIImagePickerControllerDelegate Methods
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]){
        
        if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                PHPhotoLibrary.shared().performChanges({
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection, assets: self.photosAsset) {
                        albumChangeRequest.addAssets(self.arrayImages as NSArray)
                    }
                    
                }, completionHandler: {(success, error)in
                    DispatchQueue.main.async(execute: {
                        //get the selected image or the image from the camera
                        picker.dismiss(animated: true, completion: nil)
                    })
                })
                
                //add the picture to the array
                self.arrayImages.append(image) //result.image!
                self.arrayImageId.append("new")
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Core Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        self.region = MKCoordinateRegionMake(myLocation, span)
        
        self.locationVersion1 = Float(location.coordinate.latitude)
        self.locationVersion2 = Float(location.coordinate.longitude)
    }
    
}
