//
//  MyGenresViewController.swift
//  CouldKitHackProject33
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit
import CloudKit

class MyGenresViewController: UITableViewController {
    
    var myGenres: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        if let savedGenres = defaults.object(forKey: "myGenres") as? [String] {
            myGenres = savedGenres
        } else {
            myGenres = [String]()
        }
        
        title = "Notify me about..."
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    func saveTapped() {
        let defaults = UserDefaults.standard
        defaults.set(myGenres, forKey: "myGenres")
        
        let database = CKContainer.default().publicCloudDatabase
        
        database.fetchAllSubscriptions {[unowned self] (subscriptions, error) in
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        database.delete(withSubscriptionID: subscription.subscriptionID) { (str, error) in
                            if error != nil {
                                // do your error handling here!
                                print(error!.localizedDescription)
                            }
                        }
                    }
                    for genre in self.myGenres {
                        let predicate = NSPredicate(format: "genre = %@", genre)
                        let subscription = CKQuerySubscription(recordType: "Whistles",
                                                               predicate: predicate,
                                                               options: CKQuerySubscriptionOptions.firesOnRecordCreation)
                        let notification = CKNotificationInfo()
                        notification.alertBody = "There's a new whistle in the \(genre) genre."
                        notification.soundName = "default"
                        
                        subscription.notificationInfo = notification
                        
                        database.save(subscription) { (result, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
            } else {
                // do your error handling here!
                print(error!.localizedDescription)
            }
        }
    }
    
    
    // MARK: UITableViewDataSource 
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreViewController.genres.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let genre = SelectGenreViewController.genres[indexPath.row]
        cell.textLabel?.text = genre
        
        if myGenres.contains(genre) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let selectedGenre = SelectGenreViewController.genres[indexPath.row]
            
            if cell.accessoryType == .none {
                cell.accessoryType = .checkmark
                myGenres.append(selectedGenre)
            } else {
                cell.accessoryType = .none
                
                if let index = myGenres.index(of: selectedGenre) {
                    myGenres.remove(at: index)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
