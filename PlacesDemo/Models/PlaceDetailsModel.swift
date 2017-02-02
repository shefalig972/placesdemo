//
//  PlaceDetailsModel.swift
//  PlacesDemo
//
//  Created by Talentelgia on 31/01/17.
//  Copyright © 2017 Talentelgia. All rights reserved.
//

import UIKit

class PlaceDetailsModel: NSObject {
    
    //MARK:- Properties
    var name: String?
    var webSitename: String?
    var latitude: Double?
    var longitude: Double?
    var photoList:[String] = []
    var heightArray = [NSInteger]()
    var widthArray = [NSInteger]()
    
    //MARK:- Intialization Method.
    init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        self.name = result["name"] as? String ?? ""
        self.webSitename = result["website"] as? String ?? ""
        self.latitude = location["lat"] as? Double ?? 0.0
        self.longitude = location["lng"] as? Double ?? 0.0
        if let photos = result["photos"] as? NSArray {
            if photos.count > 0{
                for object in photos {
                    let st = object as AnyObject
                    let photoReference : String = st.value(forKey:"photo_reference") as! String
                    heightArray.append(st.value(forKey:"height") as! NSInteger)
                    widthArray.append(st.value(forKey:"width") as! NSInteger)
                    photoList.append(photoReference)
                    print(photoList)
                }
            }
        }
        print(self.webSitename!)
    }
}

