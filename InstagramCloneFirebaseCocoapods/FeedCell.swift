//
//  FeedCell.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 12/4/23.
//

import UIKit
import Firebase

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
            }
        }
    }
}
