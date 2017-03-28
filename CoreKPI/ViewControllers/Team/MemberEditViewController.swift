//
//  MemberEditViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import PhoneNumberKit

class MemberEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var model = ModelCoreKPI.modelShared
    var index: Int!
    var newProfile: Profile!
    var profilePhotoData: Data!
    
    weak var memberInfoVC: MemberInfoViewController!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var memberProfilePhotoImage: UIImageView!
    @IBOutlet weak var memberNameTextField: BottomBorderTextField!
    @IBOutlet weak var memberPositionTextField: BottomBorderTextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeWaitingSpinner()
    }
    
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
    
    private func animateChanging() {
        
        if let cells = tableView.visibleCells as? [MemberEditTableViewCell]
        {
            _ = cells.map { $0.textFieldOfCell.resignFirstResponder()  }
        }
        
        let yValue = view.bounds.height * 70 / 100
        let point = CGPoint(x: view.center.x, y: yValue)
        
        addWaitingSpinner(at: point, color: OurColors.blue)
        
        saveButton.isEnabled = false
        memberNameTextField.resignFirstResponder()
        memberPositionTextField.resignFirstResponder()
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
            switch indexPath.row {
            case 0:
                let phoneCell = tableView.dequeueReusableCell(withIdentifier: "phoneNumber") as! MemberEditTableViewCell
                phoneCell.headerOfCell.text = "Phone"
                phoneCell.phoneNumberTextField.text = newProfile.phone
                phoneCell.textFieldOfCell.placeholder = "No Phone"
                phoneCell.textFieldOfCell.keyboardType = .numberPad
                phoneCell.textFieldOfCell.tag = indexPath.row + 2
                phoneCell.prepareForReuse()
                return phoneCell
            case 1:
                let cellMemberEdit = tableView.dequeueReusableCell(withIdentifier: "MemberInfoEdit", for: indexPath) as! MemberEditTableViewCell
                cellMemberEdit.headerOfCell.text = "E-mail"
                cellMemberEdit.textFieldOfCell.text = newProfile.userName
                cellMemberEdit.textFieldOfCell.placeholder = "No E-mail"
                cellMemberEdit.textFieldOfCell.keyboardType = .emailAddress
                cellMemberEdit.textFieldOfCell.tag = indexPath.row + 2
                cellMemberEdit.prepareForReuse()
                return cellMemberEdit
            default:
                break
            }
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
        
        if checkInputValue()
        {
            animateChanging()
            
            if newProfile.typeOfAccount == .Admin && model.team[index].isAdmin == false || newProfile.typeOfAccount == .Manager && model.team[index].isAdmin == true {
                changeUserRights(typeOfAccount: newProfile.typeOfAccount, success: {
                    
                    self.createDataForRequest(accountWasChanged: true)
                })
            }
            else
            {
                createDataForRequest(accountWasChanged: false)
            }            
        }
        else { return }
    }
    
    //MARK: - Check input value
    func checkInputValue() -> Bool {
        
        if self.memberNameTextField.text == "" {
            //showAlert(title: "Error saving", message: "Name text field is empty")
            return false
        } else {
            let name = self.memberNameTextField.text?.components(separatedBy: " ")
            if (name?.count)! < 2 || name?[0] == "" || name?[1] == "" || name?[0] == " " || name?[1] == " "{
                //self.showAlert(title: "Error", message: "Member should have first name and last name")
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
            //showAlert(title: "Error", message: "Email text field is empty")
            return false
        } else {
            
            if self.newProfile.userName.range(of: "@") == nil || (self.newProfile.userName.components(separatedBy: "@")[0].isEmpty) ||  (self.newProfile.userName.components(separatedBy: "@")[1].isEmpty) {
                //showAlert(title: "Error", message: "Invalid E-mail adress")
                return false
            }
        }
        
        if newProfile.phone != nil {
            let phoneNumberKit = PhoneNumberKit()
            do {
                _ = try phoneNumberKit.parse(newProfile.phone!)
            }
            catch {
                //showAlert(title: "Error", message: "Phone number incorect")
                return false
            }
        }
        return true
    }
    
    func createDataForRequest(accountWasChanged: Bool) {
        var firstname: String?
        var lastname: String?
        var position: String?
        var phone: String?
        var email: String?
        var photo: String?
        var newParams: [String : String?] = [:]
        let typeOfAccountWasChanged = accountWasChanged
        
        if newProfile.photo == "New photo link" {
            let image = memberProfilePhotoImage.image?.resized(toWidth: CGFloat(320.0))
            let imageData: NSData = UIImagePNGRepresentation(image!)! as NSData
            photo = imageData.base64EncodedString(options: .lineLength64Characters)
            profilePhotoData = UIImagePNGRepresentation(image!)!
            newParams["photo"] = photo
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
            
            if phone == nil {
                newParams["phone"] = ""
            } else {
                let phoneNumberKit = PhoneNumberKit()
                do {
                    let phoneNumber = try phoneNumberKit.parse(phone!)
                    let countryCode = phoneNumber.countryCode
                    let nationalNumber = phoneNumber.adjustedNationalNumber()
                    newParams["phone"] = "\(countryCode)\(nationalNumber)"
                }
                catch {
                    print("Generic parser error")
                }
                
            }
        }
        if newProfile.userName != model.team[index].username {
            email = newProfile.userName
            newParams["username"] = email
        }
        if newParams.count > 0 {
            sendRequest(params: newParams)
        } else if newParams.count < 1 && typeOfAccountWasChanged == true {
            self.updateProfile(photoLink: nil)
            let nc = NotificationCenter.default
            nc.post(name: .modelDidChanged,
                    object: nil,
                    userInfo: nil)
            
            self.navigationController!.popViewController(animated: true)
        } else {
            saveButton.isEnabled = true
            showAlert(title: "Warning", errorMessage: "Profile not changed")
        }
        
    }
    
    func sendRequest(params : [String : String?] ) {
        
        let request = ChangeProfile(model: model)
        
        request.changeProfile(userID: Int(model.team[index].userID) , params: params, success: { link in
            self.updateProfile(photoLink: link)
            let nc = NotificationCenter.default
            nc.post(name: .modelDidChanged,
                    object: nil,
                    userInfo:nil)
            _ = self.navigationController?.popViewController(animated: true)
        }, failure: { error in
            self.showAlert(title: "Error", errorMessage: error)
        })
    }
    
    func changeUserRights(typeOfAccount: TypeOfAccount, success: @escaping ()->()) {
        
        let request = ChangeUserRights(model: model)
        
        request.changeUserRights(userID: Int(model.team[index].userID), typeOfAccount: typeOfAccount,
                                 success: {
                                    print("TypeOfAccount was changed")
                                    success()
        },
                                 failure: { error in
                                    self.showAlert(title: "Error", errorMessage: error)
        })
    }
    
    func updateProfile(photoLink: String?) {
        
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        
        model.team[index].setValue(newProfile.userName, forKey: "username")
        model.team[index].setValue(newProfile.firstName, forKey: "firstName")
        model.team[index].setValue(newProfile.lastName, forKey: "lastName")
        model.team[index].setValue(newProfile.nickname, forKey: "nickname")
        model.team[index].setValue(newProfile.typeOfAccount == .Admin ? true : false, forKey: "isAdmin")
        model.team[index].setValue(newProfile.phone, forKey: "phoneNumber")
        model.team[index].setValue(newProfile.position, forKey: "position")
        
        if newProfile.photo != nil && newProfile.photo != model.team[index].photoLink {
            //self.model.team[index].setValue(profilePhotoData, forKey: "photo")
            self.model.team[index].photo = profilePhotoData as NSData!
            if photoLink != nil {
                //self.model.team[index].setValue(photoLink, forKey: "photoLink")
                self.model.team[index].photoLink = photoLink!
            }
        }
        
        do {
            try context.save()
        } catch {
            print(error)
            return
        }
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
        if let newPhoto = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            memberProfilePhotoImage.image = newPhoto
            memberProfilePhotoImage.contentMode = UIViewContentMode.scaleAspectFill
            memberProfilePhotoImage.clipsToBounds = true
            newProfile.photo = "New photo link"
            
            saveButton.isEnabled = checkInputValue() ? true : false
        } else{
            print("Something went wrong")
        }
                
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - updateModelDelegate method
//extension MemberEditViewController: updateModelDelegate {
//    func updateModel(model: ModelCoreKPI) {
//        self.model = ModelCoreKPI(model: model)
//    }
//}

//MARK: - updateTypeOfAccountDelegate method
extension MemberEditViewController: updateTypeOfAccountDelegate {
    func updateTypeOfAccount(typeOfAccount: TypeOfAccount) {
        self.newProfile.typeOfAccount = typeOfAccount
        tableView.reloadData()
        saveButton.isEnabled = checkInputValue() ? true : false
    }
}

//MARK: - UITextFieldDelegate method
extension MemberEditViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        switch textField.tag {
        case 2:
            switch string {
            case "0"..."9", "+", "-", "", "(", ")":
                self.newProfile.phone = txtAfterUpdate
                if txtAfterUpdate == "+" {
                    newProfile.phone = nil
                }
                if txtAfterUpdate == "" {
                    newProfile.phone = nil
                    textField.text = "+"
                    return false
                }
                saveButton.isEnabled = checkInputValue() ? true : false
                return true
            default:
                return false
            }
        case 3:
            newProfile.userName = txtAfterUpdate
            saveButton.isEnabled = checkInputValue() ? true : false
            return true
        default:
            saveButton.isEnabled = checkInputValue() ? true : false
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == memberNameTextField {
            memberPositionTextField.becomeFirstResponder()
        }
        if textField == memberPositionTextField {
            let indexPath = IndexPath(item: 0, section: tableView.numberOfSections - 1)
            let cell = tableView.cellForRow(at: indexPath) as! MemberEditTableViewCell
            cell.textFieldOfCell.becomeFirstResponder()
        }
        if textField.tag == 3 {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            if newProfile.phone == nil {
                textField.text = "+"
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 2 {
            if newProfile.phone == nil {
                textField.text = ""
            }
        }
    }
    
}
