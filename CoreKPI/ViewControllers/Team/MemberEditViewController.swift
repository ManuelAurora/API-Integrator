//
//  MemberEditViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class MemberEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var model: ModelCoreKPI!
    var index: Int!
    var newProfile: Profile!
    
    weak var memberInfoVC: MemberInfoViewController!
    
    let modelDidChangeNotification = Notification.Name(rawValue:"modelDidChange")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberNameTextField: BottomBorderTextField!
    @IBOutlet weak var memberPositionTextField: BottomBorderTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.memberNameTextField.text = "\(model.team[index].firstName!) \(model.team[index].lastName!)"
        self.memberPositionTextField.text = model.team[index].position
        
        if let photoData = model.team[index].photo {
            memberProfilePhotoImage.image = UIImage(data: photoData as Data)
        }
        
        self.newProfile = Profile(userId: Int(model.team[index].userID), userName: model.team[index].username!, firstName: model.team[index].firstName!, lastName: model.team[index].lastName!, position: model.team[index].position, photo: model.team[index].photoLink, phone: model.team[index].phoneNumber, nickname: model.team[index].nickname, typeOfAccount: model.team[index].isAdmin ? .Admin : .Manager)
        
        tableView.tableFooterView = UIView(frame: .zero)
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TableViewDatasource methods
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userId != Int(model.team[index].userID) {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userId != Int(model.team[index].userID) {
                return 1
            } else {
                fallthrough
            }
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userId != Int(model.team[index].userID) {
                let cellTypeOfAccount = tableView.dequeueReusableCell(withIdentifier: "TypeOfAccount", for: indexPath) as! TypeAccountTableViewCell
                cellTypeOfAccount.typeAccountLabel.text = self.newProfile.typeOfAccount.rawValue
                return cellTypeOfAccount
            } else {
                fallthrough
            }
        case 1:
            let cellMemberEdit = tableView.dequeueReusableCell(withIdentifier: "MemberInfoEdit", for: indexPath) as! MemberEditTableViewCell
            switch indexPath.row {
            case 0:
                cellMemberEdit.headerOfCell.text = "Phone"
                cellMemberEdit.textFieldOfCell.text = newProfile.phone
                cellMemberEdit.textFieldOfCell.placeholder = "No Phone"
                cellMemberEdit.textFieldOfCell.keyboardType = .numberPad
                cellMemberEdit.textFieldOfCell.tag = 0
            case 1:
                cellMemberEdit.headerOfCell.text = "E-mail"
                cellMemberEdit.textFieldOfCell.text = newProfile.userName
                cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
                cellMemberEdit.textFieldOfCell.keyboardType = .emailAddress
                cellMemberEdit.textFieldOfCell.tag = 1
            default:
                cellMemberEdit.headerOfCell.text = ""
                cellMemberEdit.textFieldOfCell.text = ""
                print("Cell create by default case")
            }
            return cellMemberEdit
        default:
            break
        }
        return UITableViewCell()
    }
    
    //MARK: - Tap edit photo
    @IBAction func tapEditPhoto(_ sender: Any) {
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
    
    //MARK: - tap Save button
    @IBAction func tapSaveButton(_ sender: Any) {
        
        if checkInputValue() {
            createDataForRequest()
        } else {
            return
        }
        
        //debug only ->
//        updateProfile()
//        let delegate: updateModelDelegate = memberInfoVC
//        delegate.updateModel(model: model)
//        self.navigationController!.popViewController(animated: true)
        //<- debug
    }
    
    //MARK: - Check input value
    func checkInputValue() -> Bool {
        
        if self.memberNameTextField.text == "" {
            showAlert(title: "Error saving", message: "Name text field is empty")
            return false
        } else {
            let name = self.memberNameTextField.text?.components(separatedBy: " ")
            if (name?.count)! < 2 || name?[0] == "" || name?[1] == "" || name?[0] == " " || name?[1] == " "{
                self.showAlert(title: "Error", message: "Member should have first name and last name")
                return false
            } else {
                self.newProfile.firstName = (name?[0])!
                self.newProfile.lastName = (name?[1])!
            }
        }
        
        if self.memberPositionTextField.text == "" {
            self.newProfile.position = nil
        } else {
            self.newProfile.position = self.memberPositionTextField.text
        }
        
        if self.newProfile.userName == "" {
            showAlert(title: "Error", message: "Email text field is empty")
            return false
        } else {
            
            if self.newProfile.userName.range(of: "@") == nil || (self.newProfile.userName.components(separatedBy: "@")[0].isEmpty) ||  (self.newProfile.userName.components(separatedBy: "@")[1].isEmpty) {
                showAlert(title: "Error", message: "Invalid E-mail adress")
                return false
            }
        }
        
        if self.newProfile.phone == "" {
            self.newProfile.phone = nil
        }
        
        return true
    }
    
    func createDataForRequest() {
        var firstname: String?
        var lastname: String?
        var position: String?
        var phone: String?
        var email: String?
        var photo: UIImage?
        var newParams: [String : String?] = [:]
        var typeOfAccountWasChanged = false
        
        if newProfile.photo == "New photo link" {
            photo = memberProfilePhotoImage.image
            let _ = sendProfilePhotoToServer(photo: photo!, success: { photoLink in
                newParams["photo"] = photoLink
                model.team[index].setValue(photoLink, forKey: "photoLink")
                self.model.team[index].setValue(UIImagePNGRepresentation(photo!) as NSData?, forKey: "photo")
            }
            )
        }
        if newProfile.firstName != model.team[index].firstName {
            firstname = newProfile.firstName
            newParams["first_name"] = firstname
        }
        if newProfile.lastName != model.team[index].lastName {
            lastname = newProfile.lastName
            newParams["last_name"] = lastname
        }
        if newProfile.position != model.team[index].position {
            position = newProfile.position
            newParams["position"] = position ?? ""
        }
        if newProfile.phone != model.team[index].phoneNumber {
            phone = newProfile.phone
            newParams["phone"] = phone ?? ""
        }
        if newProfile.userName != model.team[index].username {
            email = newProfile.userName
            newParams["username"] = email
        }
        if newProfile.typeOfAccount == .Admin && model.team[index].isAdmin == false || newProfile.typeOfAccount == .Manager && model.team[index].isAdmin == true {
            changeUserRights(typeOfAccount: newProfile.typeOfAccount)
            typeOfAccountWasChanged = true
        }
        if newParams.count > 0 {
            sendRequest(params: newParams)
        } else if newParams.count < 1 && typeOfAccountWasChanged == false {
            showAlert(title: "Warning", message: "Profile not changed")
        }
    }
    
    func sendProfilePhotoToServer(photo: UIImage, success: (_ photoLink: String)->()) -> Bool {
        //send
        success("https://photo.png")
        return false
    }
    
    func sendRequest(params : [String : String?] ) {
        
        let request = ChangeProfile(model: model)
        
        request.changeProfile(userID: Int(model.team[index].userID) , params: params, success: {
            self.updateProfile()
            let nc = NotificationCenter.default
            nc.post(name:self.modelDidChangeNotification,
                    object: nil,
                    userInfo:["model": self.model])
            let delegate: updateModelDelegate = self.memberInfoVC
            delegate.updateModel(model: self.model)
            self.navigationController!.popViewController(animated: true)
        }, failure: { error in
        self.showAlert(title: "Error", message: error)
        }
        )
    }
    
    func changeUserRights(typeOfAccount: TypeOfAccount) {
        
        let request = ChangeUserRights(model: model)
        
        request.changeUserRights(userID: Int(model.team[index].userID), typeOfAccount: typeOfAccount,
                                 success: {
        print("TypeOfAccount was changed")
        },
                                 failure: { error in
            self.showAlert(title: "Error", message: error)
        }
        )
    }
    
    func updateProfile() {
        
        model.team[index].setValue(newProfile.userName, forKey: "username")
        model.team[index].setValue(newProfile.firstName, forKey: "firstName")
        model.team[index].setValue(newProfile.lastName, forKey: "lastName")
        model.team[index].setValue(newProfile.nickname, forKey: "nickname")
        model.team[index].setValue(newProfile.typeOfAccount == .Admin ? true : false, forKey: "isAdmin")
        model.team[index].setValue(newProfile.phone, forKey: "phoneNumber")
        model.team[index].setValue(newProfile.position, forKey: "position")
        
    }
    
    //MARK: - Show alert method
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
            self.dismissKeyboard()
            let destinationVC = segue.destination as! TypeOfAccountTableViewController
            destinationVC.memberEditVC = self
            destinationVC.typeOfAccount = self.newProfile.typeOfAccount
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        self.navigationController?.presentTransparentNavigationBar()
    }
    
}

//MARK: - UIImagePickerControllerDelegate methods
extension MemberEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        let newPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage?
        memberProfilePhotoImage.image = newPhoto
        memberProfilePhotoImage.contentMode = UIViewContentMode.scaleAspectFill
        memberProfilePhotoImage.clipsToBounds = true
        newProfile.photo = "New photo link"
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - updateModelDelegate method
extension MemberEditViewController: updateModelDelegate {
    func updateModel(model: ModelCoreKPI) {
        self.model = ModelCoreKPI(model: model)
    }
}

//MARK: - updateTypeOfAccountDelegate method
extension MemberEditViewController: updateTypeOfAccountDelegate {
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount) {
        self.newProfile.typeOfAccount = typeOfAccount
        tableView.reloadData()
    }
}

//MARK: - UITextFieldDelegate method
extension MemberEditViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 0:
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            if (Int(txtAfterUpdate) != nil) || txtAfterUpdate == ""{
                self.newProfile.phone = txtAfterUpdate
                if txtAfterUpdate == "" {
                    self.newProfile.phone = nil
                }
                return true
            } else {
                return false
            }
        case 1:
            let textFieldText: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
            self.newProfile.userName = txtAfterUpdate
            return true
        default:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == memberNameTextField {
            memberPositionTextField.becomeFirstResponder()
        }
        if textField == memberPositionTextField {
            memberNameTextField.becomeFirstResponder()
        }
        return true
    }
    
}
