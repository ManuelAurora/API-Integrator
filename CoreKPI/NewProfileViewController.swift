//
//  NewProfileViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum TypeOfAccount: String {
    case Admin
    case Manager
}

class NewProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newProfileTableView: UITableView!
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    var typeOfAccout: TypeOfAccount!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imagePicker.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = tableView.dequeueReusableCell(withIdentifier: "NewProfile", for: indexPath) as! NewProfileInfoTableViewCell
        let cellTypeAccount = tableView.dequeueReusableCell(withIdentifier: "NewProfileTypeAccount", for: indexPath) as! NewProfileTypeAccountTableViewCell
        switch indexPath.row {
        case 0:
            cellInfo.newProfileTextField.placeholder = "First name"
        case 1:
            cellInfo.newProfileTextField.placeholder = "Last name"
        case 2:
            cellInfo.newProfileTextField.placeholder = "Position"
        case 3:
            cellTypeAccount.typeAccountLabel.text = ""
        default:
            cellInfo.newProfileTextField.placeholder = ""
        }
        if indexPath.row == 3 {
            return cellInfo
        } else {
            return cellTypeAccount
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
                let destinationController = segue.destination as! TypeOfAccountTableViewController
                //Настройка контроллера назначения
                destinationController.typeOfAccount = typeOfAccout
            
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        profilePhotoImageView.contentMode = UIViewContentMode.scaleAspectFill
        profilePhotoImageView.clipsToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapProfilePhoto(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Oops", message: "Access is denied", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        }
    }

    
}
