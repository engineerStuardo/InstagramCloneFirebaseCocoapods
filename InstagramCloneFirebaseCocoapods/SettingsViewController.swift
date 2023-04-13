//
//  SettingsViewController.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 6/4/23.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toVC", sender: nil)
        } catch let signOutError as NSError {
            print(signOutError)
        }
    }
}
