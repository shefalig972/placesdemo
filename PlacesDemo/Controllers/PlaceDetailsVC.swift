//
//  PlaceDetailsVC.swift
//  PlacesDemo
//
//  Created by Talentelgia on 31/01/17.
//  Copyright © 2017 Talentelgia. All rights reserved.
//

import UIKit

class PlaceDetailsVC: UIViewController {
    
    //MARK:- IBoutlets
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    //MARK:- Properties
    var placeId:String?
    var placeAddress:String?
    //MARK:- View life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        if let place = placeId{
            placeId = place
            if let placeDesc = placeAddress{
            self.detailsLabel.text = placeDesc
            }
        }
        self.getPlaceDetails(placeID:placeId!)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK:- UIButton Action Methods
    @IBAction func onBackBtnTapped(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    //MARK:- Get Place details from Google Places API
    func getPlaceDetails(placeID:String) {
        let url = URL(string:"\(PlacedetailsUrl)=\(placeID)&key=\(PlacesAPIkey)")
        let urlRequest = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print(error!)
                DispatchQueue.main.async {
                AppHelper.showAlert(message: (error?.localizedDescription)!, title: "Error", controller: self, cancelButtonTitle: "ok")
                }
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
            guard let placeData = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)as? [String: AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The placeData is: \(placeData.description)")
                let details = PlaceDetailsModel(json:(placeData))
                if details.photoList.count > 0 && details.widthArray.count > 0 {
                    self.callImageMethod(photoref:details.photoList[0],width:details.widthArray[0])
                }
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    //MARK:- Converting Photo reference into Photourl
    func callImageMethod(photoref:String,width:NSInteger) {
        DispatchQueue.main.async {
            AppHelper.showLoader(sender: self.view)
        }
        let url = URL(string:"\(GetImageUrl)=\(width)&photoreference=\(photoref)&key=\(PlacesAPIkey)")
        let urlRequest = URLRequest(url: url!)
        let task = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
            DispatchQueue.main.async {
            AppHelper.showAlert(message: (error?.localizedDescription)!, title: "Error", controller: self, cancelButtonTitle: "ok")
            }
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return}
            do {
                self.imageView.sd_setImage(with:response?.value(forKey:"URL")! as! URL!)
                DispatchQueue.main.async {
                    AppHelper.hideLoader(sender: self.view)
                }
                guard let imageData = try JSONSerialization.jsonObject(with: responseData, options: JSONSerialization.ReadingOptions.allowFragments)as? [String: AnyObject] else {
                        print("error trying to convert data to JSON")
                        return
                }
                print("The placeData is: \(imageData.description)")
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}


