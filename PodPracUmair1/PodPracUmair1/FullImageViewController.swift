//
//  FullImageViewController.swift
//  EventsApp
//
//  Created by Janbaz Ali on 9/14/17.
//  Copyright © 2017 Janbaz Ali. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController {
    @IBOutlet weak var imgFullView: UIImageView!
    var imgStr : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        if imgStr.isEmpty {
            
        }
        else
        {
            let url = URL(string: imgStr)
            imgFullView.sd_setShowActivityIndicatorView(true)
            imgFullView.sd_setIndicatorStyle(.whiteLarge)
            imgFullView.sd_setImage(with: url)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: false)
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
