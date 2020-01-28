//
//  EditNotesViewController.swift
//  FinalProject-ios
//
//  Created by Simran Chakkal on 2020-01-27.
//  Copyright © 2020 simran. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AVFoundation

class EditNotesViewController: UIViewController,  UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate{
      var locationManager:CLLocationManager!
    @IBOutlet var txttitle: UITextField!
    @IBOutlet var textView: UITextView!
    @IBOutlet var lblLong: UILabel!
    @IBOutlet var lblLat: UILabel!
    @IBOutlet var btnloc: UIButton!
    @IBOutlet var notesImageView: UIImageView!
    @IBOutlet var recordlbl: UIButton!
    @IBOutlet var playlbl: UIButton!
    
    
    var SoundRecorder: AVAudioRecorder!
      var SoundPlayer: AVAudioPlayer!
    
    
    
    var latitudeString:String = ""
      var longitudeString:String = ""
      // MARK: -- variables
      var note:Note!
      var notebook : Notebook?
      var userIsEditing = true
     var old = true

    // MARK: -- database
    var context:NSManagedObjectContext!
    @IBAction func getloc(_ sender: UIButton) {
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
         playlbl.isEnabled = old
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        if (userIsEditing == true) {
            print("Editing an existing note")
            txttitle.text = note.title!
            textView.text = note.text!
            self.notesImageView.image = UIImage(data: note.image! as Data)
            lblLat.text = String(note.lat)
            lblLong.text = String(note.long)
            btnloc.isHidden = false
        }
        else {
            print("Going to add a new note to: \(notebook!.name!)")
            textView.text = ""
            btnloc.isHidden = true
        }
        //determineMyCurrentLocation()
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectimage(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
               pickerController.delegate = self
               pickerController.allowsEditing = true
               
               let alertController = UIAlertController(title: "Add an Image", message: "Choose From", preferredStyle: .actionSheet)
               
               let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                   pickerController.sourceType = .camera
                   self.present(pickerController, animated: true, completion: nil)
                   }
               
               let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
                   pickerController.sourceType = .photoLibrary
                   self.present(pickerController, animated: true, completion: nil)
                   
               }
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
               alertController.addAction(cameraAction)
               alertController.addAction(photosLibraryAction)
               alertController.addAction(cancelAction)
               
               present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let imageData = image.pngData() as NSData?

       self.notesImageView.image = UIImage(data: imageData! as Data)
               self.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           //determineMyCurrentLocation()
       }
       func determineMyCurrentLocation() {
           locationManager = CLLocationManager()
           locationManager.delegate = self
           locationManager.desiredAccuracy = kCLLocationAccuracyBest
           locationManager.requestAlwaysAuthorization()
           if CLLocationManager.locationServicesEnabled() {
               locationManager.startUpdatingLocation()
               //locationManager.startUpdatingHeading()
           }
       }
       
       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           let userLocation:CLLocation = locations[0] as CLLocation
          
           note.lat = userLocation.coordinate.latitude
           note.long = userLocation.coordinate.longitude
           print("user latitude = \(userLocation.coordinate.latitude)")
           print("user longitude = \(userLocation.coordinate.longitude)")
       }
       
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
       {
           print("Error \(error)")
       }
    

    @IBAction func savenotes(_ sender: UIBarButtonItem) {
        // save text
               
               determineMyCurrentLocation()
               if (textView.text!.isEmpty) {
                   print("Please enter some text")
                   return
               }
               
               
               if (userIsEditing == true) {
                   note.text = textView.text!
               }
               else {
                   
                   // create a new note in the notebook
                   self.note = Note(context:context)
                   note.setValue(Date(), forKey:"dateAdded")
                   if (txttitle.text!.isEmpty) {
                       note.title = "No Title"
                   }
                   else{
                       note.title = txttitle.text!
                   }
                   note.text = textView.text!
                let imageData = notesImageView.image!.pngData() as NSData?
                   note.image = imageData as Data?
                  
                   note.notebook = self.notebook
               }
               
               do {
                   try context.save()
                   print("Note Saved!")
                   
                   
                   // show an alert box
                   let alertBox = UIAlertController(title: "Saved!", message: "Save Successful.", preferredStyle: .alert)
                   alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                   self.present(alertBox, animated: true, completion: nil)
               }
               catch {
                   print("Error saving note in Edit Note screen")
                   
                   // show an alert box with an error message
                   let alertBox = UIAlertController(title: "Error", message: "Error while saving.", preferredStyle: .alert)
                   alertBox.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                   self.present(alertBox, animated: true, completion: nil)
               }
               
               if (userIsEditing == false) {
                   self.navigationController?.popViewController(animated: true)
                   //self.dismiss(animated: true, completion: nil)
               }
               
               
    }
    // Recording part
    
     func getDocumentsDirector() -> URL {
         let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
             return paths[0]
         }
         
         func setupRecorder() {
          let audioFilename = getDocumentsDirector().appendingPathComponent("\(txttitle.text).m4a")
             let recordSetting = [ AVFormatIDKey : kAudioFormatAppleLossless ,
                                   AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                   AVEncoderBitRateKey : 320000,
                                   AVNumberOfChannelsKey : 2,
                                   AVSampleRateKey : 44100.2 ] as [String : Any]
             do {
                 SoundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordSetting)
                 SoundRecorder.delegate = self
                 SoundRecorder.prepareToRecord()
             } catch {
                 print(error)
             }
         }
         
         func setupPlayer() {
             let audioFilename = getDocumentsDirector().appendingPathComponent("\(txttitle.text).m4a")
             do {
                 SoundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
                 SoundPlayer.delegate = self
                 SoundPlayer.prepareToPlay()
                 SoundPlayer.volume = 1.0
             } catch {
                 print(error)
             }

         }
         
         func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
             playlbl.isEnabled = true
         }
         
         func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
             recordlbl.isEnabled = true
             playlbl.setTitle("Play", for: .normal)
         }
         
         
    @IBAction func recordbtn(_ sender: UIButton) {
      if recordlbl.titleLabel?.text == "Record" {
                         setupRecorder()
                        SoundRecorder.record()
                        recordlbl.setTitle("Stop", for: .normal)
                        playlbl.isEnabled = false
                    } else {
                        SoundRecorder.stop()
                        recordlbl.setTitle("Record", for: .normal)
                        playlbl.isEnabled = false
                    }
             
    }
    
    @IBAction func btnplay(_ sender: UIButton) {
      if playlbl.titleLabel?.text == "Play"
                    {
                            playlbl.setTitle("Stop", for: .normal)
                            recordlbl.isEnabled = false
                            setupPlayer()
                            SoundPlayer.play()
                        } else {
                        
                            SoundPlayer!.stop()
                            playlbl.setTitle("Play", for: .normal)
                            recordlbl.isEnabled = false
        }
                 
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "noteLocationSegue") {
                let locationVC = segue.destination as! NoteLocationViewController
                  let mapLat:Double = note.lat
                  let mapLong:Double = note.long
                  locationVC.latitude = mapLat
                  locationVC.longitude = mapLong
            
        }
  

}
}
