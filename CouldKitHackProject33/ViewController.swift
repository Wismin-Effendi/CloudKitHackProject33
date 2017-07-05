//
//  ViewController.swift
//  CouldKitHackProject33
//
//  Created by Wismin Effendi on 7/5/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UITableViewController {

    static var isDirty = true
    
    var whistles = [Whistle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "What's that Whistle"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Genres", style: .plain, target: self, action: #selector(selectGenre))
        
    }
    
    func selectGenre() {
        let vc = MyGenresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if ViewController.isDirty {
            loadWhistles()
        }
    }
    
    func loadWhistles() {
        // first part 
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Whistles", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["genre", "comments"]
        operation.resultsLimit = 50
        
        var newWhistles = [Whistle]()
        
        // second part 
        operation.recordFetchedBlock = { record in
            let whistle = Whistle()
            whistle.recordID = record.recordID
            whistle.genre = record["genre"] as! String
            whistle.comments = record["comments"] as! String
            newWhistles.append(whistle)
        }
        
        // third part 
        operation.queryCompletionBlock = { [unowned self] (curson, error) in
            DispatchQueue.main.async {
                if error == nil {
                    ViewController.isDirty = false
                    self.whistles = newWhistles
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(
                        title: "Fetch failed",
                        message: "There was a problem fetching the list of whistles; please try agin: \(error!.localizedDescription)",
                        preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        
        // last part
        CKContainer.default().publicCloudDatabase.add(operation)
    }

    func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline),
                               NSForegroundColorAttributeName: UIColor.purple]
        let subtitleAttributes = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.characters.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.append(subtitleString)
        }
        
        return titleString
    }

    
    // MARK: UITableViewDataSource && Delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.whistles.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = makeAttributedString(title: whistles[indexPath.row].genre, subtitle: whistles[indexPath.row].comments)
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.whistle = whistles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

