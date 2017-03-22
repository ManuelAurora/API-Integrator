//
//  OnboardingPageViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    let onboardingLodo = [#imageLiteral(resourceName: "onboarding1"), #imageLiteral(resourceName: "onboarding2"), #imageLiteral(resourceName: "onboarding3")]
    let onboardingText = [
        "Save money for your business by using CoreKPI. It has never been easier.",
        "Save your valuable time and energy with CoreKPI to focus on important things.",
        "Choose the best direction for your business with full control of your KPIs from a palm of your hand."
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        self.setViewControllers([getViewControllerAtIndex(0)] as [UIViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        self.view.backgroundColor = UIColor(red: 0/255.0, green: 188.0/255.0, blue: 212.0/255.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK:- UIPageViewControllerDataSource Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        let pageContent: OnboardingViewController = viewController as! OnboardingViewController
        
        var index = pageContent.pageIndex
        
        if ((index == 0) || (index == NSNotFound))
        {
            return nil
        }
        
        index -= 1;
        return getViewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        let pageContent: OnboardingViewController = viewController as! OnboardingViewController
        
        var index = pageContent.pageIndex
        
        if (index == NSNotFound)
        {
            return nil;
        }
        
        index += 1;
        if (index == onboardingText.count)
        {
            return nil;
        }
        return getViewControllerAtIndex(index)
    }
    
    // MARK:- Other Methods
    func getViewControllerAtIndex(_ index: NSInteger) -> OnboardingViewController
    {
        // Create a new view controller and pass suitable data.
        let onboardingViewController = self.storyboard?.instantiateViewController(withIdentifier: .onboardViewController) as! OnboardingViewController
        onboardingViewController.onboardingTextString = self.onboardingText[index]
        onboardingViewController.onboardingImage = self.onboardingLodo[index]
        onboardingViewController.pageIndex = index
        
        return onboardingViewController
    }
    
}
