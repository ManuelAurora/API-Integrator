//
//  NewProfileTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class NewProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, registerDelegate {
    
    var delegate: updateModelDelegate!
    
    var typeOfAccount: TypeOfAccount!
    var model: ModelCoreKPI!
    var request = Request()
    
    var email: String!
    var password: String!
    
    var firstName: String!
    var lastName: String!
    var position: String!
    var profileImageBase64String: String?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var typeOfAccountLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let actionViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionViewController.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.imagePickerFromCamera()
            }))
            actionViewController.addAction(UIAlertAction(title: "Choose from gallery", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.imagePickerFromPhotoLibrary()
            }))
            actionViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(actionViewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
            let destinationController = segue.destination as! TypeOfAccountTableViewController
            //Настройка контроллера назначения
            destinationController.typeOfAccount = typeOfAccount
        }
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        if firstNameTextField.text != "" || lastNameTextField.text != "" || positionTextField.text != "" {
            
            self.firstName = firstNameTextField.text
            self.lastName = lastNameTextField.text
            self.position = positionTextField.text
            registrationRequest()
            
        } else {
            let alertController = UIAlertController(title: "Warning!", message: "Text field(s) is empty!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func registrationRequest() {
        
        var data: [String : Any]!
        
        if profileImageBase64String == nil {
            data = ["username" : email, "password" : password, "first_name" : firstName, "last_name" : lastName, "position" : position, "photo" : ""]
        } else {
            data = ["username" : email, "password" : password, "first_name" : firstName, "last_name" : lastName, "position" : position, "photo" : profileImageBase64String!]
        }
        
        request.getJson(category: "/auth/createAccount", data: data,
                        success: { json in
                            self.parsingJson(json: json)
        },
                        failure: { (error) in
                            print(error)
        })
    }
    
    func parsingJson(json: NSDictionary) {
        var userId: Int
        var token: String
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = dataKey["token"] as! String
                    let profile = Profile(userId: userId, userName: email, firstName: firstName, lastName: lastName, position: position, photo: profileImageBase64String, phone: nil, nickname: nil, typeOfAccount: .Admin)
                    model = ModelCoreKPI(token: token, profile: profile)
                    let vc = storyboard?.instantiateViewController(withIdentifier: "InviteVC") as! InviteTableViewController
                    self.delegate = vc
                    delegate.updateModel(model: model)
                    navigationController?.pushViewController(vc, animated: true)
                    
                } else {
                    print("Json data is broken")
                }
            } else {
                let errorMessage = json["message"] as! String
                print("Json error message: \(errorMessage)")
                showAlert(errorMessage: errorMessage)
            }
        } else {
            print("Json file is broken!")
        }
    }
    
    func showAlert(errorMessage: String) {
        let alertController = UIAlertController(title: "Registration error", message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: registerDelegate
    
    func updateLoginAndPassword(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        profilePhotoImageView.contentMode = UIViewContentMode.scaleAspectFill
        profilePhotoImageView.clipsToBounds = true
        if let image = profilePhotoImageView.image {
            let imageData: NSData = UIImagePNGRepresentation(image)! as NSData
            self.profileImageBase64String = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
