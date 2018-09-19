//
//  HomePageViewController.swift
//  mongostich
//
//  Created by Larry Liu on 9/15/18.
//  Copyright © 2018 HopHacks18. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    

    
    // all three left side buttons cause same segway

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
        /*
         if emergencyType != ""{
         let confirmationAlert = UIAlertController(title: "EMERGENCY", message: "Emergency Responders are on their way", preferredStyle: UIAlertControllerStyle.alert)
         confirmationAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
         self.present(confirmationAlert, animated: true, completion: nil)
         }
         */
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
