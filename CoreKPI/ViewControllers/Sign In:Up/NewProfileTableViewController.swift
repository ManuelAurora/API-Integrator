//
//  NewProfileTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import Alamofire

class NewProfileTableViewController: UITableViewController {
    
    var typeOfAccount: TypeOfAccount!
    var model = ModelCoreKPI.modelShared
    
    var email: String!
    var password: String!
    var firstName: String!
    var lastName: String!
    var position: String!
    var profileImageBase64String: String?
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var profilePhotoImageView: UIImageView! {
        didSet {
            let diameter = profilePhotoImageView.bounds.width
            profilePhotoImageView.layer.cornerRadius = diameter / 2
        }
    }
    
    deinit {
        print("DEBUG: NewProfileTableVC deinitialised")
    }
    
    private var tapGesture: UITapGestureRecognizer? {
        didSet {
            guard tapGesture != nil else { return }
            view.addGestureRecognizer(tapGesture!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        saveButton.isEnabled = userInputValid()
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeWaitingSpinner()
        removeAllAlamofireNetworking()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.addTarget(self, action: #selector(userInputValid), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(userInputValid), for: .editingChanged)
        positionTextField.addTarget(self, action: #selector(userInputValid), for: .editingChanged)
        
        tableView.tableFooterView = UIView(frame: .zero)
        toggleInterface(enabled: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 && profilePhotoImageView.isUserInteractionEnabled
        {
            dismissKeyboard()
            
            let actionViewController = UIAlertController(title: nil,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
            
            actionViewController.addAction(UIAlertAction(title: "Take a photo",
                                                         style: .default,
                                                         handler: {
                                                            (action: UIAlertAction!) -> Void in
                                                            self.imagePickerFromCamera()
            }))
            
            actionViewController.addAction(UIAlertAction(title: "Choose from gallery",
                                                         style: .default,
                                                         handler: {
                                                            (action: UIAlertAction!) -> Void in
                                                            self.imagePickerFromPhotoLibrary()
            }))
            
            actionViewController.addAction(UIAlertAction(title: "Cancel",
                                                         style: .cancel,
                                                         handler: nil))
            present(actionViewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TypeOfAccount"
        {
            let destinationController = segue.destination as! TypeOfAccountTableViewController
            destinationController.typeOfAccount = typeOfAccount
        }
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
        
        toggleInterface(enabled: false)
        
        firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespaces)
        lastName  = lastNameTextField.text!.trimmingCharacters(in: .whitespaces)
        position  = positionTextField.text!.trimmingCharacters(in: .whitespaces)
        registrationRequest()
    }
    
    @objc private func toggleInterface(enabled: Bool = true) {
        
        if enabled { tapGesture = nil }
        
        navigationItem.rightBarButtonItem?.isEnabled   = enabled
        navigationItem.hidesBackButton                 = !enabled
        firstNameTextField.isUserInteractionEnabled    = enabled
        lastNameTextField.isUserInteractionEnabled     = enabled
        positionTextField.isUserInteractionEnabled     = enabled
        profilePhotoImageView.isUserInteractionEnabled = enabled
        
        if !enabled
        {
            var pos = positionTextField.center
            
            pos.y = view.bounds.height -  view.bounds.height / 4
            
            addWaitingSpinner(at: pos, color: OurColors.blue)
            
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
            positionTextField.resignFirstResponder()
        }
        else { removeWaitingSpinner() }
    }
    
    func registrationRequest() {
        
        tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(toggleInterface(enabled:)))
        
        let request = GetInviteList(model: ModelCoreKPI.modelShared)
        
        request.inviteRequest(email: email, success: { teams in
            
            if teams.count > 0
            {
                let alert = UIAlertController(title: "Select your team",
                                              message: nil,
                                              preferredStyle: .alert)
                
                teams.forEach { team in
                    let button = UIAlertAction(title: team.teamName(),
                                               style: .default,
                                               handler: { _ in
                                                let id = team.id
                                                self.register(inTeam: id)
                    })
                    alert.addAction(button)
                }
                
                let myTeam = UIAlertAction(title: "Make My Team",
                                           style: .default, handler: { _ in
                                            self.register(inTeam: 0)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: { _ in
                                                    self.toggleInterface(enabled: true)
                                                    print("Cancelled")
                })
                
                alert.addAction(cancelAction)
                alert.addAction(myTeam)
                self.present(alert, animated: true, completion: nil)
            }
            else { self.register(inTeam: 0) }
            
        }) { error in
            print(error)
            self.toggleInterface(enabled: true)
        }
    }
    
    private func register(inTeam id: Int) {
        
        let registrationRequest = RegistrationRequest()
        registrationRequest.registrationRequest(email: email,
                                                password: password,
                                                firstname: firstName,
                                                lastname: lastName,
                                                position: position,
                                                photo: profileImageBase64String,
                                                teamId: id,
                                                success: { _ in
                                                    self.segueToVC()
                                                    self.removeWaitingSpinner()
        }, failure: { error in
            self.showAlert(title: "Registration error", errorMessage: error)
            self.toggleInterface(enabled: true)
        })
    }
    
    func segueToVC() {
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin
        {
            let vc = storyboard?.instantiateViewController(withIdentifier: .inviteViewController) as! InviteTableViewController
            vc.email = email
            vc.password = password
            
            navigationController?.pushViewController(vc, animated: true)
        }
        else { UserStateMachine.shared.logInWith(email: email, password: password) }
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
    
    private func check(textfields: [UITextField]) -> Bool {
        
        let maxCharacters = 30
        var result = false
        
        textfields.forEach {
            if let charsTotal = $0.text?.characters.count, charsTotal > 0 && charsTotal <= maxCharacters {
                result = true
            }
            else { result = false }
        }
        
        return result
    }
    
    @objc fileprivate func userInputValid() -> Bool {
        
        let isInputValid = check(textfields: [firstNameTextField,
                                        lastNameTextField,
                                        positionTextField])
        
        saveButton.isEnabled = isInputValid
        
        return isInputValid
    }
    
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
extension NewProfileTableViewController
{
    func updateLoginAndPassword(email: String, password: String) {
        self.email = email
        self.password = password
    }
}
