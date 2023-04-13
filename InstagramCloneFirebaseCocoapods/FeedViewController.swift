//
//  FeedViewController.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 6/4/23.
//

import UIKit
import Firebase
import SDWebImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var emailArray = [String]()
    var commentArray = [String]()
    var likeArray = [Int]()
    var imageArray = [String]()
    var documentIdArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }
    
    func getData() {
        let db = Firestore.firestore()
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
