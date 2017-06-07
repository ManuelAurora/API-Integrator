//
//  AppDelegate.swift
//  CoreKPI
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var launchViewController: LaunchViewController!
    let stateMachine = UserStateMachine.shared
    
    static let sharedInstance = UIApplication.shared.delegate as! AppDelegate
    
    lazy var pinCodeVCPresenter: PinCodeVCPresenter = {
        
        let presenter = PinCodeVCPresenter(in: self.window!)
        
        return presenter
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        
        //stateMachine.pinCodeAttempts = UserDefaults.standard.value(forKey: UserDefaultsKeys.pinCodeAttempts) as! Int? ?? 0        
        // Override point for customization after application launch.
   
        //NavigationBar style
        UITabBar.appearance().tintColor = OurColors.violet
        UITabBar.appearance().unselectedItemTintColor = OurColors.cyan
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = OurColors.cyan
        navigationBarAppearace.backItem?.backBarButtonItem?.tintColor = OurColors.cyan
        
        //Local push notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted {
                print("Notification access denied.")
            }
            application.registerForRemoteNotifications()
        }
        
        UNUserNotificationCenter.current().delegate = self
//        
//        let later = UNNotificationAction(identifier: "remindLater", title: "Remind me later", options: [])
//        let addReport = UNNotificationAction(identifier: "addReport", title: "Add report", options: [.foreground])
//        let category = UNNotificationCategory(identifier: "myCategory", actions: [addReport, later], intentIdentifiers: [], options: [])
//        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        //scheduleLocalNotification()
        
        let viewAction = UNNotificationAction(identifier: "View_ID",
                                              title: "View",
                                              options: .foreground)
        
        let category = UNNotificationCategory(identifier: "Alert_Category",
                                              actions: [viewAction],
                                              intentIdentifiers: ["INTENT"],
                                              options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        if let launchOptions = launchOptions?[.remoteNotification] as? [String: AnyObject]
        {
            let aps = launchOptions["aps"] as? jsonDict
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var tokenString = ""
        
        deviceToken.withUnsafeBytes { (bytes: UnsafePointer<CChar>) -> Void in
            
            for i in 0..<deviceToken.count
            {
                tokenString += String(format: "%02.2hhx", arguments: [bytes[i]])
            }
        }
        
        print(tokenString)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        
    }
    
    private func scheduleLocalNotification() {
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "This is title"
        notificationContent.subtitle = "The subtitle"
        notificationContent.body = "The Body. Movin"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let notifRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification",
                                                 content: notificationContent,
                                                 trigger: trigger)
        
        UNUserNotificationCenter.current().add(notifRequest) { error in
            guard error == nil else {
                print("Unable to Add Notification Request (\(error!), \(error!.localizedDescription))")
                return
            }
        }
    }
    
    func scheduleNotification(at date: Date, title: String, message: String) {
        
        UNUserNotificationCenter.current().delegate = self
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        
        let request = UNNotificationRequest(identifier: "textNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert])
    }
    
 
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.   
        
        NotificationCenter.default.post(name: .appDidEnteredBackground, object: nil)
        
        if stateMachine.userStateInfo.loggedIn && stateMachine.usersPin != nil {
            pinCodeVCPresenter.presentPinCodeVC()
            pinCodeVCPresenter.presentedFromBG = true           
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.      
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreKPI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }    
}

// MARK: - Remind me later button did taped
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.actionIdentifier == "remindLater" {
            let newDate = Date(timeInterval: 900, since: Date())
            scheduleNotification(at: newDate, title: "CoreKPI", message: "Add report, please!")
        }
        if response.actionIdentifier == "addReport" {
            //
        }
    }
}

// MARK: handle callback url
extension AppDelegate {
    
    func applicationHandle(url: URL) {
        
        if (url.host == "oauth-callback")
        {
            OAuthSwift.handle(url: url)
        }
        else if url.host == "callback"
        {
            guard let components = URLComponents(url: url,
                                                 resolvingAgainstBaseURL: false)
                else { return }
            if let items = components.queryItems,
                items.count > 0,
                let code = items[0].value
            {
                NotificationCenter.default.post(name: .hubspotCodeRecieved,
                                                object: nil,
                                                userInfo: ["apiCode": code])
            }
        }
        else
        {
            OAuthSwift.handle(url: url)
        }
    }
    
    private func findRealmId(in url: URL) -> String {
        
        let parameters = url.absoluteString.removingPercentEncoding?.components(separatedBy: "&")
        
        if let resultArray = parameters?.filter({ $0.contains("realmId")})
        {
            if resultArray.count > 0
            {
                let realmIdString = resultArray[0]
                let index = realmIdString.index(realmIdString.startIndex, offsetBy: 8)
                let realmId = realmIdString.substring(from: index)
                return realmId
            }
        }
        return ""
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        QuickBookDataManager.shared().serviceParameters[.companyId] = findRealmId(in: url)
        applicationHandle(url: url)
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        applicationHandle(url: url)
        
        QuickBookDataManager.shared().serviceParameters[.companyId] = findRealmId(in: url)
        
        return true
    }
}

extension AppDelegate: UINavigationControllerDelegate
{
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .pop, let vc = fromVC as? KPISelectSettingTableViewController, vc.shoulUseCustomAnimation == true
        {
            return TransitionAnimator()
        }
        
        return nil
    }
    
}
