//
//  SignInViewController.swift
//  CoreKPI
//
//  Created by Семен on 15.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var model: ModelCoreKPI!
    var delegate: updateModelDelegate!
    
    @IBOutlet weak var passwordTextField: BottomBorderTextField!
    @IBOutlet weak var emailTextField: BottomBorderTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var enterByKeyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        configure(buttons: [signInButton, enterByKeyButton])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - UITextFieldDelegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            emailTextField.resignFirstResponder()
            tapSignInButton(signInButton)
        }
        return true
    }
    
    @IBAction func enterByKeyButtonTapped(_ sender: UIButton) {
        
        showPinCodeViewController()
    }
    
    @IBAction func tapSignInButton(_ sender: UIButton) {
        
        let email = emailTextField.text?.lowercased()
        let password = passwordTextField.text
        
        if email == "" || password == "" {
            
            let alertController = UIAlertController(title: "Oops", message: "Email/Password field is empty!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if email?.range(of: "@") == nil || (email?.components(separatedBy: "@")[0].isEmpty)! ||  (email?.components(separatedBy: "@")[1].isEmpty)!{
            let alertController = UIAlertController(title: "Oops", message: "Invalid E-mail adress", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        loginRequest()
    }
    
    private func configure(buttons: [UIButton]) {
        
        _ = buttons.map {
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        }
    }
    
    private func showPinCodeViewController() {
        
        guard let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: "PinCodeViewController") as? PinCodeViewController else { print("DEBUG: An error occured while trying instantiate pin code VC"); return }
        
        present(pinCodeViewController, animated: true, completion: nil)
        
    }
    
    func toggleEnterByKeyButton(isEnabled: Bool) {
        
        enterByKeyButton.layer.borderColor = isEnabled ? OurColors.violet.cgColor : UIColor.lightGray.cgColor
        enterByKeyButton.isEnabled = isEnabled
    }
    
    func loginRequest() {
        
        if let username = self.emailTextField.text?.lowercased() {
            if let password = self.passwordTextField.text {
                
                let loginRequest = LoginRequest()
                loginRequest.loginRequest(username: username, password: password,
                                          success: {(userID, token, typeOfAccount) in
                                            self.model = ModelCoreKPI(token: token, userID: userID)
                                            self.model.profile?.typeOfAccount = typeOfAccount
                                            self.saveData()
                                            self.showTabBarVC()
                },
                                          failure: { error in
                                            print(error)
                                            self.showAlert(title: "Authorization error", errorMessage: error)
                }
                )
            }
        }
    }
    
    //MARK: - segue to TabBar
    func showTabBarVC() {
        let tabBarController = storyboard?.instantiateViewController(withIdentifier: "TabBarVC") as! MainTabBarViewController
        
        let dashboardNavigationViewController = tabBarController.viewControllers?[0] as! DashboardsNavigationViewController
        let dashboardViewController = dashboardNavigationViewController.childViewControllers[0] as! KPIsListTableViewController
        dashboardViewController.model = ModelCoreKPI(model: model)
        dashboardViewController.loadKPIsFromServer()
        
        let alertsNavigationViewController = tabBarController.viewControllers?[1] as! AlertsNavigationViewController
        let alertsViewController = alertsNavigationViewController.childViewControllers[0] as! AlertsListTableViewController
        alertsViewController.model = ModelCoreKPI(model: model)
        
        let teamListNavigationViewController = tabBarController.viewControllers?[2] as! TeamListViewController
        let teamListController = teamListNavigationViewController.childViewControllers[0] as! MemberListTableViewController
        teamListController.model = ModelCoreKPI(model: model)
        teamListController.loadTeamListFromServer()
        
        present(tabBarController, animated: true, completion: nil)
    }
    
    //MARK: - show alert function
    func showAlert(title: String, errorMessage: String) {
        let alertController = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Save data
    func saveData() {
        let data: [ModelCoreKPI] = [self.model]
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encodedData, forKey: "token")
        print("Token saved in NSKeyedArchive")
    }
    
}
