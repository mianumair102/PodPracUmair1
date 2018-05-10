//
//  ActivityViewController.swift
//  EmployerSwift
//
//  Created by Janbaz Ali on 3/7/17.
//  Copyright © 2017 Mian Umair Nadeem. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {

    @IBOutlet var lblMsg: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setMessage(mssg : String?) -> Void {
        lblMsg.text = mssg!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
