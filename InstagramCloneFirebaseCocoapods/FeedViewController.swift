//
//  FeedViewController.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 6/4/23.
//

import UIKit
import Firebase
import SDWebImage
import OneSignal

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var emailArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var imageArray = [String]()
    var documentIdArray = [String]()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        getPlayerIds()
    }
    
    func getPlayerIds() {
        if let deviceState = OneSignal.getDeviceState() {
            let userId = deviceState.userId
            let email = Auth.auth().currentUser!.email!
            
            if let playerId = userId {
                db.collection("PlayerId").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
                    if error == nil {
                        if snapshot?.isEmpty == false, snapshot != nil {
                            for document in snapshot!.documents {
                                if let playerIdDB = document.get("playerId") as? String {
                                    if playerId != playerIdDB {
                                        self.addDocument(email: email, playerId: playerId)
                                    }
                                }
                            }
                        } else {
                            self.addDocument(email: email, playerId: playerId)
                        }
                    }
                }
                
            }
        }
    }
    
    func addDocument(email: String, playerId: String) {
        let playerIdDict = ["email": email, "playerId": playerId] as [String: Any]
        self.db.collection("PlayerId").addDocument(data: playerIdDict) { error in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            }
        }
    }
    
    func getData() {
        db.collection("Posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            } else {
                if snapshot?.isEmpty != true, snapshot != nil {
                    self.resetArrays()
                    for document in snapshot!.documents {
                        self.documentIdArray.append(document.documentID)
                        
                        if let postedBy = document.get("postedBy") as? String {
                            self.emailArray.append(postedBy)
                        }
                        
                        if let likes = document.get("likes") as? Int {
                            self.likeArray.append(likes)
                        }
                        
                        if let comment = document.get("postComment") as? String {
                            self.commentArray.append(comment)
                        }
                        
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.imageArray.append(imageUrl)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func resetArrays() {
        emailArray.removeAll()
        likeArray.removeAll()
        commentArray.removeAll()
        imageArray.removeAll()
        documentIdArray.removeAll()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        cell.emailLabel.text = emailArray[indexPath.row]
        cell.likeLabel.text = String(likeArray[indexPath.row])
        cell.commentLabel.text = commentArray[indexPath.row]
        cell.postImage.sd_setImage(with: URL(string: imageArray[indexPath.row]))
        cell.documentId = documentIdArray[indexPath.row]
        
        return cell
    }

}
