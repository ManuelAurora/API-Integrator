//
//  UserStateMachine.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 21.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit //Just for appDelegate usage
import CoreData

struct UserStateInfo
{
    var loggedIn        = false
    var didEnterBG      = false
    var usesPinCode     = false
    var haveLocalToken  = false
    var wasLoaded       = false
    var isFetchingData  = false
    var tryingToLogIn   = false
    var invitationsLeft = 0
}

class UserStateMachine
{
    //MARK: *Properties
    //Private instance properties section
    private let notificationCenter = NotificationCenter.default
    private lazy var appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
     
    //Class-static section
    static let shared = UserStateMachine()
    
    //Open instance properties section
    let model = ModelCoreKPI.modelShared
    let networkManager = NetworkingManager.shared
    var userStateInfo = UserStateInfo()
    
    var isAdmin: Bool {
        return model.profile?.typeOfAccount == TypeOfAccount.Admin
    }
    
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
    
    func getNumberOfInvitations() {
        
        let request = GetNumberOfInvations(model: model)
        request.getNumberOfInvations(success: { value in
            self.userStateInfo.invitationsLeft = value
        }, failure: { _ in
            self.userStateInfo.invitationsLeft = 0
        })
    }
    
    private func userLoggedIn() {
        
        pinCodeAttempts = usersPin != nil ? PinLockConfiguration.attempts : 0
        userStateInfo.loggedIn = true       
        userStateInfo.haveLocalToken = true
        setTryingToLogin(false)
        getNumberOfInvitations()
        notificationCenter.post(name: .userLoggedIn, object: nil)
        
        let tvc = appDelegate.launchViewController.mainTabBar.teamListController
        tvc.loadTeamListFromServer()
    }
    
    private func userLoggedOut() {
        
        userStateInfo.loggedIn       = false
        userStateInfo.haveLocalToken = false
        userStateInfo.usesPinCode    = false
        
        let regVc      = appDelegate.launchViewController.registerViewController
        let mainTab    = appDelegate.launchViewController.mainTabBar
        let dashboard  = mainTab.dashboardViewController
        let teamVc     = mainTab.teamListController
        let alertVc    = mainTab.alertsViewController
        
        regVc.emailTextField?.text = ""
        regVc.passwordTextField?.text = ""
        regVc.repeatPasswordTextField?.text = ""
        
        model.team.forEach { context.delete($0) }
        model.kpis.removeAll()
        model.team.removeAll()
        model.profile = nil
        model.token = nil
        dashboard.arrayOfKPI.removeAll()
        dashboard.tableView.reloadData()
        teamVc.tableView.reloadData()
        alertVc.tableView.reloadData()
        
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
        
        getNumberOfInvitations()
    }
}
