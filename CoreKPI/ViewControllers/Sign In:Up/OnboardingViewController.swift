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

        onboardingText.text = onboardingTextString
        onboardingImageView.image = onboardingImage
        pageControl.currentPage = pageIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getStartedButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
