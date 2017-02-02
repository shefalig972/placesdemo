//
//  PlaceModel.swift
//  PlacesDemo
//
//  Created by Talentelgia on 31/01/17.
//  Copyright © 2017 Talentelgia. All rights reserved.
//

import UIKit

 class PlaceModel: NSObject {
    
    //MARK:- Properties
     let id:String?
     let desc:String?
    
    //MARK:- Intialization Method.
      init(prediction: [String: AnyObject]) {
        self.id          =  prediction["place_id"] as? String ?? ""
        self.desc        = prediction["description"] as? String ?? ""
    }
}
