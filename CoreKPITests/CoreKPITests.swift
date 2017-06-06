//
//  CoreKPITests.swift
//  CoreKPITests
//
//  Created by Семен on 13.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import XCTest
import CoreData
@testable import CoreKPI

class CoreKPITests: XCTestCase {
    
    var storyboard: UIStoryboard! = nil
    var launchVC: LaunchViewController! = nil
    var kpiList: KPIsListTableViewController! = nil
    var supportVC: SupportMainTableViewController! = nil
    var regVc: RegisterViewController! = nil
    var memberList: MemberListTableViewController! = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var managedContext: NSManagedObjectContext! = nil
    let model = UserStateMachine.shared.model
    var stateMachine = UserStateMachine.shared
    
    override func setUp() {
        super.setUp()
        
        managedContext = appDelegate.persistentContainer.viewContext
        fillModel()
        launchVC   = appDelegate.launchViewController
        regVc = appDelegate.launchViewController.registerVC
        launchVC.mainTabBar.model = model
        
        memberList = MemberListTableViewController.storyboardInstance() { vc in
            vc.model = model
            vc.model = model
        }
        
        kpiList   = launchVC.mainTabBar.dashboardViewController
        kpiList.model = model
        supportVC = launchVC.mainTabBar.supportMainTableVC
        supportVC.model = model
        
        supportVC.viewDidLoad()
        launchVC.showTabBarVC()
        kpiList.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private func fillModel() {
      
        stateMachine.userStateInfo.loggedIn       = true
        stateMachine.userStateInfo.haveLocalToken = true
        stateMachine.userStateInfo.usesPinCode    = true
        model.team = [Team(context: managedContext), Team(context: managedContext)]
        model.kpis = [KPI(kpiID: 1, typeOfKPI: .createdKPI),
                      KPI(kpiID: 1, typeOfKPI: .createdKPI)]
        model.profile = Profile(userID: 22)
        model.token = "TokenForSmiServer"
        
        model.alerts = [Alert(), Alert()]
    }
    
    func testCoreDataModels() {
        
        //let external = ExternalKPI(context: managedContext)
        let gaEntity = GoogleKPI(context: managedContext)
        gaEntity.oAuthToken = "Token"
        gaEntity.oAuthToken = "RefreshToken"
        gaEntity.oAuthTokenExpiresAt = NSDate()
        gaEntity.siteURL = "LOL.com"
        gaEntity.viewID = "Trinta"
    }
    
    func testProperLogOut() {
        
        var valuesAreProperlyChanged = false
        
        regVc.emailTextField = BottomBorderTextField()
        regVc.passwordTextField = BottomBorderTextField()
        regVc.repeatPasswordTextField = BottomBorderTextField()
      
        regVc.emailTextField!.text          = "test@gmail.com"
        regVc.passwordTextField!.text       = "123456"
        regVc.repeatPasswordTextField!.text = "155626"
        
        appDelegate.launchViewController.mainTabBar.teamListController.model = model
        appDelegate.launchViewController.mainTabBar.alertsViewController.model = model
        supportVC.stateMachine.logOut()       
        
        if stateMachine.userStateInfo.loggedIn == false &&
            stateMachine.userStateInfo.haveLocalToken == false &&
            stateMachine.userStateInfo.usesPinCode == false &&
            regVc.emailTextField?.text == "" &&
            regVc.passwordTextField?.text == "" &&
            regVc.repeatPasswordTextField?.text == "" &&
            model.team.count == 0 &&
            model.kpis.count == 0 &&
            model.profile == nil &&
            (model.token == nil || model.token == "")
        {
            valuesAreProperlyChanged = true
        }
        
        XCTAssertTrue(valuesAreProperlyChanged)        
    }
    
    func testKPIListHaveModel() {
        
        XCTAssertNotNil(kpiList.model, "Model cannot be nil in this place")
    }
}
