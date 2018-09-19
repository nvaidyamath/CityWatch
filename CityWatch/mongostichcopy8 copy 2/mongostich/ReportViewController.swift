//
//  ReportViewController.swift
//  mongostich
//
//  Created by Nikhil Vaidyamath on 9/15/18.
//  Copyright © 2018 HopHacks18. All rights reserved.
//

import UIKit
import StitchCoreSDK
import StitchCore
import CoreLocation
import StitchRemoteMongoDBService
import StitchAWSService
import StitchCoreAWSService
class ReportViewController: UIViewController,UINavigationControllerDelegate,CLLocationManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate {
    var stitchClient = Stitch.defaultAppClient!
    var slideVal = 0.0
    var location = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    @IBOutlet var priorityLabel: UILabel!
    @IBOutlet var headlineText: UITextField!
    @IBOutlet var summaryText: UITextField!
    @IBOutlet var sliderVal: UISlider!
    var SlideValRound = 0
    @IBAction func sliderMoved(_ sender: Any) {
        slideVal = Double(((sliderVal.value)*10))
        print(slideVal)
        slideVal.round()
        print(slideVal)
        let stringSlideVal = String(format: "%.2f", slideVal)
        print(stringSlideVal)
        priorityLabel.text = stringSlideVal
    }
    @IBAction func uploadImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        print("uploaded")
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler:nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageToPost.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet var imageToPost: UIImageView!
    
    @IBOutlet var reportButton: UIButton!
    func smallImage(from image: UIImage) -> UIImage? {
        let size = image.size.applying(CGAffineTransform(scaleX: 0.125, y: 0.125))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    func getImageFromS3(withUUID uuid: String, completion: @escaping (UIImage) -> Void) {
        let awsURL = URL(string: "https://s3.us-east-2.amazonaws.com/citywatchimages/")
        guard let url = awsURL?.appendingPathComponent(uuid) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            }
        }
    }
    @IBAction func reportButtonTapped(_ sender: Any) {
        guard let image = imageToPost.image, let scaledImage = smallImage(from: image), let png = UIImagePNGRepresentation(scaledImage) else {
            return
        }
        
        let imageUUID = UUID().uuidString
        let aws = stitchClient.serviceClient(fromFactory: awsServiceClientFactory, withName: "AWS")
        let args: Document = ["Bucket": "citywatchimages",
                              "Key": imageUUID,
                              "ACL": "public-read",
                              "ContentType": "image/png",
                              "Body": Binary(data: png, subtype: .binary)
        ]
        
        let request = AWSRequestBuilder()
            .with(service: "s3")
            .with(action: "PutObject")
            .with(region: "us-east-2")
            .with(arguments: args)
        
        guard let requestBuilt = try? request.build() else {
            return
        }
        
        aws.execute(request: requestBuilt) { (result: StitchResult<Document>) in
            switch result {
            case .success(let awsResult):
                // move below code into new function call here where you set the url in the doc
                // find S3 key if needed
                print("success")
                
            case .failure(let error):
                print("failure")
                print(error)
            }
        }
        var mongoClient = stitchClient.serviceClient(fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas")
        var itemsCollection = mongoClient.db("Reports").collection("report_collection")
        var documentToInsert: Document = [
            "reporter_id": stitchClient.auth.currentUser?.id,
            "Headline": headlineText.text,
            "Summary": summaryText.text,
            "Priority": slideVal,
            "coordinates": [location.latitude,location.longitude]
        ]
        itemsCollection.insertOne(documentToInsert) { result in
            switch result {
            case .success(_):
                print("sucess")
            case .failure(let error):
                print("Failed to insert document: \(error)")
            }
            
        }
        DispatchQueue.main.async {
            itemsCollection.find().asArray { (result) in
                switch result {
                case .success(let results):
                    for doc in results {
                        print(doc)
                    }
                case .failure(let error):
                    print("Error in finding documents: \(error)")
                }
            }
        }
        
        getImageFromS3(withUUID: imageUUID) { (image) in
            self.imageToPost.image = image
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] as CLLocation
        location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    var emergencyType = ""
    @IBAction func emergencyTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "EMERGENCY", message: "Are you in an immediate emergency?", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default,handler: {[weak alertController, weak self] (_) in
            let secondAlert = UIAlertController(title: "EMERGENCY", message: "What type of emergency are you facing?", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            secondAlert.addAction(UIAlertAction(title: "Armed Attack/Burglary", style: UIAlertActionStyle.destructive,handler: {[weak secondAlert, weak self] (_) in self?.emergencyType = "Armed Attack/Burglary"
                if self?.emergencyType != ""{
                    let confirmationAlert = UIAlertController(title: "EMERGENCY", message: "Police are on their way", preferredStyle: UIAlertControllerStyle.alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                }
            }))
            
            secondAlert.addAction(UIAlertAction(title: "Assault (Physical/Sexual)", style: UIAlertActionStyle.destructive,handler: {[weak secondAlert, weak self] (_) in self?.emergencyType = "Assault"
                if self?.emergencyType != ""{
                    let confirmationAlert = UIAlertController(title: "EMERGENCY", message: "Police are on their way", preferredStyle: UIAlertControllerStyle.alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                }
            }))
            
            secondAlert.addAction(UIAlertAction(title: "Medical Emergency", style: UIAlertActionStyle.destructive,handler: {[weak secondAlert, weak self] (_) in self?.emergencyType = "Medical Emergency"
                if self?.emergencyType != ""{
                    let confirmationAlert = UIAlertController(title: "EMERGENCY", message: "Paramedics are on their way", preferredStyle: UIAlertControllerStyle.alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                }
            }))
            
            secondAlert.addAction(UIAlertAction(title: "Other", style: UIAlertActionStyle.destructive,handler: {[weak secondAlert, weak self] (_) in self?.emergencyType = "Other"
                if self?.emergencyType != ""{
                    let confirmationAlert = UIAlertController(title: "EMERGENCY", message: "Emergency Responders are on their way", preferredStyle: UIAlertControllerStyle.alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                }
            }))
            
            secondAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: nil))
            self?.present(secondAlert, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
