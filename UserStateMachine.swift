//
//  UserStateMachine.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 21.03.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit //Just for appDelegate usage

struct UserStateInfo {
    var loggedIn       = false
    var didEnterBG     = false
    var usesPinCode    = false
    var haveLocalToken = false
    var wasLoaded      = false
}

class UserStateMachine
{
    //MARK: *Properties
    //Private instance properties section
    private let notificationCenter = NotificationCenter.default
    private let appDelegate = UIApplication.shared .delegate as! AppDelegate
    private var usersPin: [String]? {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCode) as? [String]
    }
    
    //Class-static section
    static let shared = UserStateMachine()
    
    //Open instance properties section
    let model = ModelCoreKPI.modelShared
    var userStateInfo = UserStateInfo()
    
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
    
    func logInWith(email: String, password: String) {
        
        let loginRequest = LoginRequest()
        loginRequest.loginRequest(username: email, password: password,
                                  success: {(userID, token, typeOfAccount) in
                                    let profile = Profile(userID: userID)
                                    profile.typeOfAccount = typeOfAccount
                                    self.model.signedInUpWith(token: token, profile: profile)
                                    self.saveLocalToken()
                                    self.userLoggedIn()                                    
        },
                                  failure: { error in
                                    print(error)
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
        
        appDelegate.loggedIn   = true
        userStateInfo.loggedIn = true       
        userStateInfo.haveLocalToken = true
        notificationCenter.post(name: .userLoggedIn, object: nil)
    }
    
    private func userLoggedOut() {
        
        self.notificationCenter.post(name: .userLoggedOut, object: nil)
        
        let context = appDelegate.persistentContainer.viewContext
        
        appDelegate.loggedIn         = false
        userStateInfo.loggedIn       = false
        userStateInfo.haveLocalToken = false
        userStateInfo.usesPinCode    = false
        
        _ = model.team.map { context.delete($0) }
        
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.token)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.pinCode)        
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
    
    //Notifications handlers
    @objc private func userSetPin() { userStateInfo.usesPinCode = true; appDelegate.loggedIn = true }
    
    @objc private func userRemovedPin() { userStateInfo.usesPinCode = false }
    
    @objc private func modelDidChanged() {
        
    }
}
