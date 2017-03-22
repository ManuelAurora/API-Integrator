//
//  PayPalAuthViewController.swift
//  CoreKPI
//
//  Created by Семен on 06.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class PayPalAuthViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var activateButton: UIBarButtonItem!
    
    var ChooseSuggestedKPIVC: ChooseSuggestedKPITableViewController!
    var selectedService: IntegratedServices!
    var serviceKPI: [(SettingName: String, value: Bool)]!
    
    var profileName: String? = nil
    var apiUsername: String? = nil
    var apiPassword: String? = nil
    var apiSignature: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activateButton = self.navigationItem.rightBarButtonItem
        self.hideKeyboardWhenTappedAround()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.isScrollEnabled = false
        activateButton.isEnabled = false
    }
    
    @IBAction func activateButtonDidTaped(_ sender: UIBarButtonItem) {
        checkAPICredentials()
    }
    
    func checkAPICredentials() {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.activityIndicatorViewStyle = .gray
        let barButton = UIBarButtonItem(customView: activityIndicator)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        activityIndicator.startAnimating()
        
        let request = PayPal(apiUsername: apiUsername!, apiPassword: apiPassword!, apiSignature: apiSignature!)
        request.getAccountInfo(success: {
            self.prepareForUnwind()
            activityIndicator.stopAnimating()
        }, failure: {error in
            activityIndicator.stopAnimating()
            self.navigationItem.setRightBarButton(self.activateButton, animated: true)
            print(error)
            let alertController = UIAlertController(title: "Authorisation error", message: "Please check input values", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        })
    }
    
    func prepareForUnwind() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        let payPalKPI = PayPalKPI(context: context)
        
        payPalKPI.profileName = profileName
        payPalKPI.apiUsername = apiUsername
        payPalKPI.apiPassword = apiPassword
        payPalKPI.apiSignature = apiSignature
        
        var settingDelegate: updateSettingsDelegate!
        ChooseSuggestedKPIVC.integrated = selectedService
        settingDelegate = ChooseSuggestedKPIVC
        settingDelegate.updateSettingsArray(array: serviceKPI)
        
        let payPalDelegate: UpdatePayPalAPICredentialsDelegate = ChooseSuggestedKPIVC
        payPalDelegate.updatePayPalCredentials(payPalObject: payPalKPI)
        let stackVC = navigationController?.viewControllers
        _ = navigationController?.popToViewController((stackVC?[(stackVC?.count)! - 4])!, animated: true)
    }

    func checkInputValues() -> Bool {
        if profileName != nil && apiUsername != nil && apiPassword != nil && apiSignature != nil {
            activateButton.isEnabled = true
            return true
        } else {
            activateButton.isEnabled = false
            return false
        }
    }

}

extension PayPalAuthViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayPalAPI") as! PayPalAuthTableViewCell
        cell.apiTextField.returnKeyType = .next
        cell.apiTextField.tag = indexPath.row
        
        switch indexPath.row {
        case 0:
            cell.apiLabel.text = "Profile name"
        case 1:
            cell.apiLabel.text = "API username"
        case 2:
            cell.apiLabel.text = "API password"
        case 3:
            cell.apiLabel.text = "API signature"
            cell.apiTextField.returnKeyType = .continue
        default:
            break
        }
        return cell
    }
}

extension PayPalAuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0...2:
            let cell = tableView.cellForRow(at: IndexPath(item: textField.tag + 1, section: 0)) as! PayPalAuthTableViewCell
            cell.apiTextField.becomeFirstResponder()
        case 3:
            let cell = tableView.cellForRow(at: IndexPath(item: textField.tag, section: 0)) as! PayPalAuthTableViewCell
            cell.apiTextField.resignFirstResponder()
            if checkInputValues() {
                activateButtonDidTaped(activateButton)
            } else {
                let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as! PayPalAuthTableViewCell
                cell.apiTextField.becomeFirstResponder()
            }
            
        default:
            break
        }
        _ = checkInputValues()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let txtAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        switch textField.tag {
        case 0:
            profileName = (txtAfterUpdate == "" ? nil : txtAfterUpdate)
        case 1:
            apiUsername = (txtAfterUpdate == "" ? nil : txtAfterUpdate)
        case 2:
            apiPassword = (txtAfterUpdate == "" ? nil : txtAfterUpdate)
        case 3:
            apiSignature = (txtAfterUpdate == "" ? nil : txtAfterUpdate)
        default:
            break
        }
        _ = checkInputValues()
        return true
    }
    
}
