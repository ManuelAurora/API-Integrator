//
//  NewProfileTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class NewProfileTableViewController: UITableViewController {
    
    var delegate: updateModelDelegate!
    
    var typeOfAccount: TypeOfAccount!
    var model = ModelCoreKPI.modelShared
    
    var email: String!
    var password: String!
    
    var firstName: String!
    var lastName: String!
    var position: String!
    var profileImageBase64String: String?
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            dismissKeyboard()
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
            destinationController.typeOfAccount = typeOfAccount
        }
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        if firstNameTextField.text != "" || lastNameTextField.text != "" || positionTextField.text != "" {
            
            firstName = firstNameTextField.text
            lastName = lastNameTextField.text
            position = positionTextField.text
            registrationRequest()
            
        } else {
            showAlert(title: "Warning!", errorMessage: "Text field(s) is empty!")
        }
    }
    
    func registrationRequest() {
        
        let registrationRequest = RegistrationRequest()
        registrationRequest.registrationRequest(email: email, password: password, firstname: firstName, lastname: lastName, position: position, photo: profileImageBase64String,
                                                success: { _ in
                                                    self.segueToVC()
        }, failure: { error in
            self.showAlert(title: "Registration error", errorMessage: error)
        })
    }
    
    func segueToVC() {
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            let vc = storyboard?.instantiateViewController(withIdentifier: "InviteVC") as! InviteTableViewController
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! MainTabBarViewController
            
            let dashboardNavigationViewController = tabBarController.viewControllers?[0] as! DashboardsNavigationViewController
            let dashboardViewController = dashboardNavigationViewController.childViewControllers[0] as! KPIsListTableViewController
            dashboardViewController.model = model
            dashboardViewController.loadKPIsFromServer()
            
            let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
            let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
            alertsViewController.model = model
            
            let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
            let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
            teamListController.model = model
            
            present(tabBarController, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: UIImagePickerControllerDelegate methods
extension NewProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerFromPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profilePhotoImageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        profilePhotoImageView.contentMode = UIViewContentMode.scaleAspectFill
        profilePhotoImageView.clipsToBounds = true
        if let image = profilePhotoImageView.image {
            let imageData: NSData = UIImagePNGRepresentation(image)! as NSData
            profileImageBase64String = imageData.base64EncodedString(options: .lineLength64Characters)
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate method
extension NewProfileTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        if textField == lastNameTextField {
            positionTextField.becomeFirstResponder()
        }
        if textField == positionTextField {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            positionTextField.resignFirstResponder()
            tapSaveButton(self.navigationItem.rightBarButtonItem!)
        }
        return true
    }
}

//MARK: registerDelegate
extension NewProfileTableViewController: registerDelegate {
    func updateLoginAndPassword(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
