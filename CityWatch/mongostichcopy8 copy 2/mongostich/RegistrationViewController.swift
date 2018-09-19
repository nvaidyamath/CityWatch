//
//  RegistrationViewController.swift
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

class RegistrationViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate  {
    
    @IBOutlet var firstNameText: UITextField!
    @IBOutlet var lastNameText: UITextField!
    var stitchClient = Stitch.defaultAppClient!
    @IBOutlet var imageToPost: UIImageView!
    
    @IBAction func uploadImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        print("uploaded")
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        
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
    
    @IBAction func registerButton(_ sender: Any) {
        guard let image = imageToPost.image, let scaledImage = smallImage(from: image), let png = UIImagePNGRepresentation(scaledImage) else {
            return
        }
        
        let imageUUID = UUID().uuidString
        
        if firstNameText.text != "" && lastNameText.text != "" {
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
            var itemsCollection = mongoClient.db("Users").collection("accounts")
            let number = Int(arc4random_uniform(6))
            var documentToInsert: Document = [
                "user_id": stitchClient.auth.currentUser?.id,
                "f_name": firstNameText.text,
                "l_name": lastNameText.text,
                "rating": number,
                "img_id": imageUUID
                ]
            itemsCollection.insertOne(documentToInsert) { result in
                switch result {
                case .success(_):
                    print("sucess")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "registerToHome", sender: nil)
                    }
                case .failure(let error):
                    print("Failed to insert document: \(error)")
                }
                
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please fill both first and last name", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        getImageFromS3(withUUID: imageUUID) { (image) in
            self.imageToPost.image = image
        }
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func initializeTextFields() {
        firstNameText.delegate = self as! UITextFieldDelegate
        firstNameText.keyboardType = UIKeyboardType.asciiCapable
        lastNameText.delegate = self as! UITextFieldDelegate
        lastNameText.keyboardType = UIKeyboardType.asciiCapable
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

        // Do any additional setup after loading the view.
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
