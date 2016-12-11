//
//  ViewController.swift
//  RedRuleBlueRule
//
//  Created by Potari Gabor on 2016. 12. 11..
//  Copyright © 2016. Potari Gabor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        let primVC = UIStoryboard(name: "PrimAlgorithm", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(primVC, animated: true)
    }

}

