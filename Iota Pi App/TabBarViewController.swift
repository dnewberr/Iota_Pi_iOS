//
//  TabBarViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 2/21/17.
//  Copyright © 2017 Deborah Newberry. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.unselectedItemTintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
