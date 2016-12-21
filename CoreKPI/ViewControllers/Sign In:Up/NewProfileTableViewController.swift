//
//  NewProfileTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum TypeOfAccount: String {
    case Admin
    case Manager
}


class NewProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, registerDelegate {
    
    var typeOfAccount: TypeOfAccount!
    var model: ModelCoreKPI!
    var request = Request()
    
    var email: String! = "dogAndCat@mail.ru"
    var password: String! = "1"
    
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
        
        //imagePicker.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    /*override func numberOfSections(in tableView: UITableView) -> Int {
     // #warning Incomplete implementation, return the number of sections
     return 1
     }*/
    
    /* override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // #warning Incomplete implementation, return the number of rows
     return 5
     }*/
    
    
    /*override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "TypeOfAccount", for: indexPath) as! NewProfileTypeAccountTableViewCell
     if indexPath.row == 4 {
     if let type = typeOfAccount {
     type == .Admin ? (cell.typeAccountLabel.text = "Admin") : (cell.typeAccountLabel.text = "Manager")
     } else {
     cell.typeAccountLabel.text = ""
     }
     }
     return cell
     }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let actionViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actionViewController.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.imagePickerFromCamera()
            }))
            actionViewController.addAction(UIAlertAction(title: "Pick from Photo Library", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.imagePickerFromPhotoLibrary()
            }))
            actionViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(actionViewController, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
            
           // self.profileImageBase64String = UIImagePNGRepresentation(image)? as! NSData.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
            //print(temp ?? "error convert")
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TypeOfAccount" {
            let destinationController = segue.destination as! TypeOfAccountTableViewController
            //Настройка контроллера назначения
            destinationController.typeOfAccount = typeOfAccount
            
        }
    }
    
    func updateLoginAndPassword(email: String, password: String) {
        self.email = email
        self.password = password
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
            //username, password, first_name, last_name, position*, photo*
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
        }
        )
        
    }
    
    func parsingJson(json: NSDictionary) {
        var userId: Int!
        var token: String!
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                if let dataKey = json["data"] as? NSDictionary {
                    userId = dataKey["user_id"] as! Int
                    token = "123456789"//dataKey["token"] as! String
                    let profile = Profile(userName: email, firstName: firstName, lastName: lastName, position: position, photo: profileImageBase64String)
                    model = ModelCoreKPI(userId: userId, token: token, profile: profile)
                    let vc = storyboard?.instantiateViewController(withIdentifier: "InviteVC")
                    navigationController?.pushViewController(vc!, animated: true)
                    
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
    
    
    //
    //    @IBAction func tapProfilePhoto(_ sender: Any) {
    //
    //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
    //
    //            imagePicker.allowsEditing = false
    //            imagePicker.sourceType = .photoLibrary
    //
    //            self.present(imagePicker, animated: true, completion: nil)
    //        } else {
    //            let alertController = UIAlertController(title: "Oops", message: "Access is denied", preferredStyle: .alert)
    //            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //            self.present(alertController, animated: true, completion: nil)
    //
    //        }
    //    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
