//
//  UserStateMachine.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 21.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit //Just for appDelegate usage

struct UserStateInfo
{
    var loggedIn       = false
    var didEnterBG     = false
    var usesPinCode    = false
    var haveLocalToken = false
    var wasLoaded      = false
    var isFetchingData   = false
    var tryingToLogIn  = false
}

class UserStateMachine
{
    //MARK: *Properties
    //Private instance properties section
    private let notificationCenter = NotificationCenter.default
    private lazy var appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    //Class-static section
    static let shared = UserStateMachine()
    
    //Open instance properties section
    let model = ModelCoreKPI.modelShared
    var userStateInfo = UserStateInfo()
    var usersPin: [String]? {
        let pin = UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCode) as? [String]
        return pin
    }
    
    var pinCodeAttempts: Int {
        get {
            return UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCodeAttempts) as? Int ?? 0
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.pinCodeAttempts)
        }
    }

    //MARK: *Initializers
    init() {
        subscribeToNotifications()
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    //MARK: *Open functions
    func prepareToLogin() {
        
        if checkUserHaveLocalToken() { userStateInfo.haveLocalToken = true }
    }
    
    func toggleAppFetchingData() {
        
        userStateInfo.isFetchingData = !userStateInfo.isFetchingData
    }
    
    func checkTokenOnServer() {
        
        let req = LoginRequest(model: model)
        req.checkToken(success: { data in
            self.model.token = data.token
            self.model.profile?.userId = data.userID
            self.model.profile?.typeOfAccount = data.typeOfAccount
            self.getDataFromCoreData()
            self.userLoggedIn()
        }, failure: { error in
            if error == "" { //TODO: Токен невалидный
                self.getDataFromCoreData()
                self.logOut()
            } else {
                self.getDataFromCoreData()
                self.userLoggedIn()
            }
            print(error)
        })
    }
    
    func logOut() { userLoggedOut() }
    
    //This value informes us about app was loaded once. 
    //Needs for escaping bug when switching roots.
    func makeLoaded() { userStateInfo.wasLoaded = true }
    
    func setTryingToLogin(_ state: Bool) {
        userStateInfo.tryingToLogIn = state
    }
    
    func logInWith(email: String, password: String) {        
        
        setTryingToLogin(true)
        let loginRequest = LoginRequest()
        loginRequest.loginRequest(username: email, password: password,
                                  success: {(userID, token, typeOfAccount) in
                                    self.setTryingToLogin(false)
                                    let profile = Profile(userID: userID)
                                    profile.typeOfAccount = typeOfAccount
                                    self.model.signedInUpWith(token: token, profile: profile)
                                    self.saveLocalToken()
                                    self.userLoggedIn()
        },
                                  failure: { error in
                                    self.setTryingToLogin(false)
                                    self.notificationCenter.post(name: .userFailedToLogin,
                                                                 object: nil,
                                                                 userInfo: ["error": error])
        })
    }
    
    //MARK: *Private functions
    private func getDataFromCoreData() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        do {
            //model.alerts = try context.fetch(Alert.fetchRequest())
            model.team = try context.fetch(Team.fetchRequest())
            notificationCenter.post(name: .modelDidChanged, object: nil)
        } catch {
            print("Fetching faild")
        }
    }

    private func checkUserHaveLocalToken() -> Bool {
        
        if let token = UserDefaults.standard.object(forKey: UserDefaultsKeys.token)
        {
            let userID = UserDefaults.standard.integer(forKey: UserDefaultsKeys.userId)
            
            guard userID != 0 else { print("DEBUG: User ID equals 0"); return false }
            
            let profile = Profile(userID: userID)
            
            model.profile = profile
            model.token = token as! String
            
            return true
        } else {
            print("No local token in app storage")
            return false
        }
    }
    
    private func userLoggedIn() {
        
        pinCodeAttempts = usersPin != nil ? PinLockConfiguration.attempts : 0
        userStateInfo.loggedIn = true       
        userStateInfo.haveLocalToken = true
        setTryingToLogin(false)
        
        notificationCenter.post(name: .userLoggedIn, object: nil)
    }
    
    private func userLoggedOut() {
        
        let context = appDelegate.persistentContainer.viewContext
        
        userStateInfo.loggedIn       = false
        userStateInfo.haveLocalToken = false
        userStateInfo.usesPinCode    = false
        
        let mainTab    = appDelegate.launchViewController.mainTabBar
        let teamListVC = mainTab.teamListController
        let dashboard  = mainTab.dashboardViewController
        
        teamListVC.tableView.visibleCells.forEach { cell in
            guard let c = cell as? MemberListTableViewCell else { return }
            c.aditionalBackground.layer.borderWidth = 0
            c.aditionalBackground.layer.borderColor = UIColor.white.cgColor
        }
        
        let hsObject = HubSpotManager.sharedInstance.hubspotKPIManagedObject
        
        if let extKpi = hsObject.externalKPI,
            let kpis = extKpi.allObjects as? [ExternalKPI]
        {
            kpis.forEach { context.delete($0) }
        }
        
        model.team.forEach { context.delete($0) }
        model.kpis.removeAll()
        model.team.removeAll()
        dashboard.arrayOfKPI.removeAll()
        dashboard.tableView.reloadData()
        
        try? context.save()
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token)
        userRemovedPin()
        
        notificationCenter.post(name: .userLoggedOut, object: nil)
    }
    
    private func subscribeToNotifications() {
        
        notificationCenter.addObserver(self,
                                       selector: #selector(UserStateMachine.modelDidChanged),
                                       name: .modelDidChanged,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(UserStateMachine.userSetPin),
                                       name: .userAddedPincode,
                                       object: nil)
        
        notificationCenter.addObserver(self,
                                       selector: #selector(UserStateMachine.userRemovedPin),
                                       name: .userRemovedPincode,
                                       object: nil)
        
        notificationCenter.addObserver(forName: .appDidEnteredBackground,
                                       object: nil,
                                       queue: nil) { _ in
                                        self.userStateInfo.didEnterBG = true
        }
    }
    
    private func saveLocalToken() {
        
        UserDefaults.standard.set(model.profile.userId, forKey: UserDefaultsKeys.userId)
        UserDefaults.standard.set(model.token, forKey: UserDefaultsKeys.token)
    }
    
    func setNew(pincode: [String]?) {
        
        UserDefaults.standard.set(pincode, forKey: UserDefaultsKeys.pinCode)
        pinCodeAttempts = PinLockConfiguration.attempts
    }
    
    //Notifications handlers
    @objc private func userSetPin() { userStateInfo.usesPinCode = true }
    
    @objc private func userRemovedPin() {
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.pinCode)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.pinCodeAttempts)
        userStateInfo.usesPinCode = false
    }
    
    @objc private func modelDidChanged() {
        
    }
}
