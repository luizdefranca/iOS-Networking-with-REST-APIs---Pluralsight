//
//  ViewController.swift
//  RESThub
//
//  Created by Harrison on 7/25/19.
//  Copyright © 2019 Harrison. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var feedTableView: UITableView!
    
    // MARK: Variables

    var feedGists: [Gist] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
        // TODO: GET a list of gists
        fetchGist()


    }

    @IBAction func createNewGist(_ sender: UIButton) {

        DataService.shared.createNewGist { (result) in
            DispatchQueue.main.async {
                switch result {
                    case .success(let json):
                        self.showResultAlert(title: "Great !!", message: "New post successfully created")
                        print(json)
                    case .failure(let error):
                        self.showResultAlert(title: "Oops !!", message: "Somenthing get wrong")
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Utilities
    func showResultAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: UITableView Delegate & DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedGists.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCellID", for: indexPath)
        let gist = self.feedGists[indexPath.row]
        cell.textLabel?.text = gist.description == "" ? "Empty description" : gist.description
        cell.detailTextLabel?.text = gist.id
//        cell.imageView?.image = gist
        return cell;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let starAction = UIContextualAction(style: .normal, title: "Star") { (action, view, completion) in
            
            // TODO: PUT a gist star
            if let id = self.feedGists[indexPath.row].id {
                self.starUnstarGist(turnOn: true, id: id )
            }
            completion(true)
        }
        
        let unstarAction = UIContextualAction(style: .normal, title: "Unstar") { (action, view, completion) in
            
            // TODO: DELETE a gist star
             if let id = self.feedGists[indexPath.row].id {
                           self.starUnstarGist(turnOn: false, id: id )
            }
            completion(true)
        }
        
        starAction.backgroundColor = .blue
        unstarAction.backgroundColor = .darkGray
        
        let actionConfig = UISwipeActionsConfiguration(actions: [unstarAction, starAction])
        return actionConfig
    }
    
}

extension ViewController {
    func starUnstarGist(turnOn: Bool, id: String) {
        DataService.shared.starnUnstarGist(id: id, star: turnOn) { (success) in
            DispatchQueue.main.async {

                if success {
                    self.showResultAlert(title: "Great", message: turnOn ? "Gist successfully starred!" : "Gist successfully unstarred!")
                    print("Gist successfully changed")
                } else {
                    self.showResultAlert(title: "Ooops!", message: "Something get wrong!! :(")
                    print("Fail changing Gist")
                }
            }
        }
    }

    func fetchGist(){

        DataService.shared.fetchGists { (result) in

            DispatchQueue.main.async {
                switch result {
                case .success(let gists):
                    print(dump(gists))
                    self.feedGists = gists
                    self.feedTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }

//               let testGist = Gist(id: nil, isPublic: true, description: "Hello test", files: ["test.txt": File(content: "testing")])

//               print("*******************************")
//               do {
//                   let gistData = try JSONEncoder().encode(testGist)
//                   let stringData = String(data: gistData, encoding: .utf8)
//                   print(stringData as Any)
//               } catch  {
//                   print(error.localizedDescription)
//               }

    }
}
