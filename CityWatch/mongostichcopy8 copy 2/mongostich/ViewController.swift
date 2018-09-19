//
//  ViewController.swift
//  mongostich
//
//  Created by Nikhil Vaidyamath on 9/15/18.
//  Copyright © 2018 HopHacks18. All rights reserved.
//

import UIKit
import StitchCoreSDK
import StitchCore
import StitchRemoteMongoDBService
import StitchAWSService
import StitchCoreAWSService

class ViewController: UIViewController, UITextFieldDelegate {

    var stitchClient = Stitch.defaultAppClient
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var emailText: UITextField!
    
    @IBOutlet var signIn: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var emergencyButton: UIButton!
    var emergencyType = ""
    @IBAction func logInButton(_ sender: Any) {
        let credential = UserPasswordCredential.init(withUsername:emailText.text!,withPassword:passwordText.text!)
        Stitch.defaultAppClient?.auth.login(withCredential: credential, { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signInToHome", sender: nil)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let loginAlert = UIAlertController(title: "Error", message: "Error logging in with email/password auth", preferredStyle: UIAlertControllerStyle.alert)
                    loginAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(loginAlert, animated: true, completion: nil)
                }
            }
            
        })
    }

    @IBAction func signUpButton(_ sender: Any) {
        var val=0
        let emailPassClient = Stitch.defaultAppClient!.auth.providerClient(
            fromFactory: userPasswordClientFactory
        )
        emailPassClient.register(withEmail: emailText.text!, withPassword: passwordText.text!) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signInToRegister", sender: nil)
                }
                print("Registration email sent")
            case .failure(let error):
                val=1
                print("Error sending registration email")
            }
        }
        if val == 0 {
            performSegue(withIdentifier: "signInToRegister", sender: nil)
        }
    }
    
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func initializeTextFields() {
        emailText.delegate = self as! UITextFieldDelegate
        emailText.keyboardType = UIKeyboardType.asciiCapable
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        // Do any additional setup after loading the view, typically from a nib.
        passwordText.isSecureTextEntry = true
        
        signIn.layer.shadowColor = UIColor.black.cgColor
        signIn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        signIn.layer.masksToBounds = false
        signIn.layer.shadowRadius = 0.25
        signIn.layer.shadowOpacity = 0.5
        signIn.layer.cornerRadius = signIn.frame.width / 4
        
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        registerButton.layer.masksToBounds = false
        registerButton.layer.shadowRadius = 0.25
        registerButton.layer.shadowOpacity = 0.5
        registerButton.layer.cornerRadius = registerButton.frame.width / 4
        
        emergencyButton.layer.shadowColor = UIColor.black.cgColor
        emergencyButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        emergencyButton.layer.masksToBounds = false
        emergencyButton.layer.shadowRadius = 0.25
        emergencyButton.layer.shadowOpacity = 0.5
        emergencyButton.layer.cornerRadius = emergencyButton.frame.width / 4

        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

//        let client = Stitch.defaultAppClient!
//
//        print("logging in anonymously")
//        client.auth.login(withCredential: AnonymousCredential()) { result in
//            switch result {
//            case .success(let user):
//                print("logged in anonymous as user \(user.id)")
//                DispatchQueue.main.async {
//                    // update UI accordingly
//                }
//            case .failure(let error):
//                print("Failed to log in: \(error)")
//            }
//
//        }
