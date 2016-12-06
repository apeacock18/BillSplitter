//
//  MeViewController.swift
//  BillSplitter
//
//  Created by gomeow on 5/2/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class MeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    let imagePicker = UIImagePickerController()
    @IBOutlet weak var avatar: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.image = VariableManager.getAvatar()
        emailLabel.text = VariableManager.getEmail()
        nameLabel.text = VariableManager.getName()


        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func avatarButton(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            avatar.image = pickedImage
            NetworkManager.sendAvatarToServer(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
