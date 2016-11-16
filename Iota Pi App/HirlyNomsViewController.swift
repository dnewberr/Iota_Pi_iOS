//
//  HirlyNomsViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 11/14/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit

class HirlyNomsViewController: UIViewController {
    @IBOutlet weak var definitionLabel: UILabel!
    @IBOutlet weak var hirlyNomReasonText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hirlyNomReasonText.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        hirlyNomReasonText.layer.borderWidth = 1.0
        hirlyNomReasonText.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
