//
//  ProfileViewController.swift
//  CityWatchAntoine
//
//  Created by Larry Liu on 9/15/18.
//  Copyright © 2018 HopHacks18. All rights reserved.
//

import UIKit
import StitchCoreSDK
import StitchCore
import StitchRemoteMongoDBService
import StitchAWSService
import StitchCoreAWSService
class ProfileViewController: UIViewController {
    
    var emergencyType = ""
    var stitchClient = Stitch.defaultAppClient!
    
    @IBOutlet var fullNameText: UILabel!
    
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
    
    @IBOutlet weak var empty1: UIImageView!
    @IBOutlet weak var empty2: UIImageView!
    @IBOutlet weak var empty3: UIImageView!
    @IBOutlet weak var empty4: UIImageView!
    @IBOutlet weak var empty5: UIImageView!
    var stars = [UIImageView]()
    @IBOutlet weak var starLabel: UILabel!
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
    @IBOutlet weak var image: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.getImageFromS3(withUUID: "461D897E-EA78-4D22-BFF1-28FFB999D271", completion: { (imagerec) in
            self.image.image = imagerec
        })
        var starRating = 0
        stars.append(empty1)
        stars.append(empty2)
        stars.append(empty3)
        stars.append(empty4)
        stars.append(empty5)
        var mongoClient = stitchClient.serviceClient(fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas")
        var itemsCollection = mongoClient.db("Users").collection("accounts")
        var imageUUID = UUID().uuidString
        var firstName = String()
        var lastName = String()
        itemsCollection.find().asArray { (result) in
            switch result {
            case .success(let results):
                for doc in results {
                    if doc["user_id"] as? String == self.stitchClient.auth.currentUser?.id {
                        firstName = doc["f_name"] as! String
                        lastName = doc["l_name"] as! String
                        imageUUID = doc["img_id"] as! String
                    }
                }
            case .failure(let error):
                print("Error in finding documents: \(error)")
            }
        }
        print(lastName, firstName, starRating, imageUUID, 1)
        
        DispatchQueue.main.async {
            print(lastName, firstName, starRating, imageUUID, 1)
            for i in 0..<starRating {
                print(i)
                self.stars[i].image = UIImage(named: "filled.png")
            }
            self.fullNameText.text = firstName + " " + lastName
            self.getImageFromS3(withUUID: imageUUID, completion: { (imagerec) in
                self.image.image = imagerec
            })
        }
        
        starLabel.text = String(starRating) + " / 5"
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.black.cgColor
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
