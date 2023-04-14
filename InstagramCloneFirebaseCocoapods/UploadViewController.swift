//
//  UploadViewController.swift
//  InstagramCloneFirebaseCocoapods
//
//  Created by Italo Stuardo on 6/4/23.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionText: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let tapCloseGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapCloseGesture)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func selectImage() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true,completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        let mediaFolder = Storage.storage().reference().child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let imageReference = mediaFolder.child("\(UUID().uuidString).jpg")
            imageReference.putData(data) { metadata, error in
                if error != nil {
                    self.alert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let post = ["imageUrl": imageUrl!, "postedBy": Auth.auth().currentUser!.email!, "postComment": self.descriptionText.text!, "date": FieldValue.serverTimestamp(), "likes": 0] as [String: Any]
                            
                            //DATABASE
                            let db = Firestore.firestore()
                            db.collection("Posts").addDocument(data: post) { error in
                                if error != nil {
                                    self.alert(title: "Error", message: error?.localizedDescription ?? "Error")
                                } else {
                                    self.alert(title: "Successfuly", message: "Post was created successfuly!!")
                                    self.descriptionText.text = ""
                                    self.imageView.image = UIImage(named: "placeholder-image.jpg")
                                    self.tabBarController?.selectedIndex = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
    
}
