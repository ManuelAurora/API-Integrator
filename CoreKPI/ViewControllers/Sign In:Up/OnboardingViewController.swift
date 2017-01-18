//
//  OnboardingViewController.swift
//  CoreKPI
//
//  Created by Семен on 17.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    var pageIndex = 0
    var onboardingTextString: String = ""
    var onboardingImage: UIImage = UIImage()
    
    @IBOutlet weak var onboardingImageView: UIImageView!
    @IBOutlet weak var onboardingText: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.onboardingText.text = onboardingTextString
        self.onboardingImageView.image = onboardingImage
        self.pageControl.currentPage = pageIndex
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStartedButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
