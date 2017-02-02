//
//  AppHelper.swift
//  PlacesDemo
//
//  Created by Talentelgia on 31/01/17.
//  Copyright © 2017 Talentelgia. All rights reserved.
//

import UIKit

class AppHelper: NSObject {
    
    //MARK:- UIAlertController Method
    class func showAlert(message: String, title: String ,controller:UIViewController,cancelButtonTitle:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        controller .present(alertController, animated:true, completion:nil)
    }
    
    //MARK:- MBProgressHUD Methods
    class func showLoader(sender:UIView){
        var hud = MBProgressHUD()
        hud = MBProgressHUD.showAdded(to: sender, animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.label.text = "Loading..."
    }
    class func hideLoader(sender:UIView){
        MBProgressHUD.hide(for: sender, animated: true)
    }

}
