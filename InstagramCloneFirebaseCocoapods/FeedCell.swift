//
//  FeedCell.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 12/4/23.
//

import UIKit
import Firebase
import OneSignal

class FeedCell: UITableViewCell {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    
    var documentId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func like(_ sender: Any) {
        if let likeCount = Int(likeLabel.text!) {
            if let id = documentId {
                let likeDict = ["likes": likeCount + 1] as [String: Any]
                
                let db = Firestore.firestore()
                db.collection("Posts").document(id).setData(likeDict, merge: true)
                
                let userEmail = emailLabel.text!
                db.collection("PlayerId").whereField("email", isEqualTo: userEmail).getDocuments { snapshot, error in
                    if error == nil {
                        if snapshot?.isEmpty == false, snapshot != nil {
                            for document in snapshot!.documents {
                                if let id = document.get("playerId") as? String {
                                    let content: [String : Any] = [
                                        "contents": ["en": "\(Auth.auth().currentUser!.email!) liked your post"],
                                        "headings": ["en": "Instagram Clone"],
                                        "include_player_ids": [id],
                                        "data" : ["action" : "custom_action"]
                                    ]
                            
                                    OneSignal.postNotification(content, onSuccess: {
                                        osResultSuccessBlock in print("This is the result: \(osResultSuccessBlock.debugDescription)")
                                        },
                                        onFailure: {
                                          osFailureBlock in print("This is the error: \(osFailureBlock.debugDescription)")
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
