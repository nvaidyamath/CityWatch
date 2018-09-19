//
//  SocialTableViewController.swift
//  mongostich
//
//  Created by Nikhil Vaidyamath on 9/16/18.
//  Copyright © 2018 HopHacks18. All rights reserved.
//

import UIKit
import StitchCoreSDK
import StitchCore
import StitchRemoteMongoDBService
import StitchAWSService
import StitchCoreAWSService
class SocialTableViewController: UITableViewController {
    var stitchClient = Stitch.defaultAppClient!
    var Posts = [[Any]]()
    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    
       
//        var mongoClient = stitchClient.serviceClient(fromFactory: remoteMongoClientFactory, withName: "mongodb-atlas")
//        var headLine = String()
//        var summary =  String()
//        var coordinates = (Int)()
//        var itemsCollection = mongoClient.db("Published").collection("published_collection")
//        itemsCollection.find().asArray { (result) in
//            switch result {
//            case .success(let results):
//                for doc in results {
//                    if doc["publisher_id"] as? String != self.stitchClient.auth.currentUser?.id {
//                        headLine = (doc["Headline"] as? String)!
//                        summary = (doc["Summary"] as? String)!
//                        coordinates = (doc["coordinates"] as? (Int))!
//                        var array = [Any]()
//                        array = [headLine,summary,coordinates]
//                        self.Posts.append(array)
//                        self.tableView.reloadData()
//                        array=[]
//                    }
//                }
//            case .failure(let error):
//                print("Error in finding documents: \(error)")
        
    

        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        
//        return cell
//    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
