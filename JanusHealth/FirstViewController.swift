//
//  FirstViewController.swift
//  JanusHealth
//
//  Created by bayers on 11/17/18.
//  Copyright © 2018 bayers. All rights reserved.
//


///////////////////////////// NOT USING THIS!!!! ALL CODE MOVED TO TABBARVIEWCONTROLLER!!

import UIKit
import CareKit
import ResearchKit

class FirstViewController: UIViewController {
    fileprivate let carePlanStoreManager = CarePlanStoreManager.sharedCarePlanStoreManager
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let careCardStack = createCareCardStack()
    }
    
    fileprivate func createCareCardStack() -> UINavigationController {
        let viewController = OCKCareCardViewController(carePlanStore: carePlanStoreManager.store)
        //        viewController.maskImage = UIImage(named: "heart")
        //        viewController.smallMaskImage = UIImage(named: "small-heart")
        //        viewController.maskImageTintColor = UIColor.darkGreen()
        
        viewController.tabBarItem = UITabBarItem(title: "Zombie Training", image: UIImage(named: "carecard"), selectedImage: UIImage(named: "carecard-filled"))
        viewController.title = "Zombie Training"
        return UINavigationController(rootViewController: viewController)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }


}

