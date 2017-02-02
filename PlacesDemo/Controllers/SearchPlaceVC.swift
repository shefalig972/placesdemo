//
//  SearchPlaceVC.swift
//  PlacesDemo
//
//  Created by Talentelgia on 31/01/17.
//  Copyright © 2017 Talentelgia. All rights reserved.
//

import UIKit

class SearchPlaceVC: UIViewController {
    
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet var searchTxtFld: UITextField!
    //MARK:- Properties
    var apiKey: String?
    var places = [PlaceModel]()
    //MARK:- View life cycles
    override  func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isHidden = true
    }
    //MARK:- Get List of Places from Google Places API.
    func getPlaces(searchString: String) {
        let search = searchString
        if (searchString == ""){
            return }
        self.requestForPlaces(url:"\(SearchPlaceUrl)=\(PlacesAPIkey)&input=\(search)") { json, error in
            if let json = json{
                print(json)
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    self.places = predictions.map { (prediction: [String: AnyObject]) -> PlaceModel in
                        return PlaceModel(prediction: prediction)
                    }
                }
                self.tableView.reloadData()
                self.tableView.isHidden = false
            }
        }
    }
    func requestForPlaces(url: String,completion: @escaping (NSDictionary?,NSError?) -> ()) {
        let request = NSMutableURLRequest(
            url: NSURL(string: "\(url)?") as! URL)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            self.handleResponse(data: data as NSData!,response: response as? HTTPURLResponse, error: error as NSError!, completion: completion)
        }
        task.resume()
    }
    func handleResponse(data: NSData!, response: HTTPURLResponse!, error: NSError!, completion: @escaping (NSDictionary?, NSError?) -> ()) {
        let done: ((NSDictionary?, NSError?) -> Void) = {(json, error) in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion(json,error)
            })
        }
        if let error = error {
            print("GooglePlaces Error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                AppHelper.showAlert(message: error.localizedDescription, title: "Error", controller: self, cancelButtonTitle: "ok")
            }
            done(nil,error)
            return
        }
        if response == nil {
            print("GooglePlaces Error: No response from API")
            let error = NSError(domain: ErrorDomain, code: 1001, userInfo: [NSLocalizedDescriptionKey:"No response from API"])
            DispatchQueue.main.async {
                AppHelper.showAlert(message: "No response from API", title: "Error", controller: self, cancelButtonTitle: "ok")
            }
            
            done(nil,error)
            return
        }
        if response.statusCode != 200 {
            print("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            let error = NSError(domain: ErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey:"Invalid status code"])
            done(nil,error)
            return
        }
        let json: NSDictionary?
        do {
            json = try JSONSerialization.jsonObject(
                with: data as Data,
                options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
        } catch {
            print("Serialisation error")
            let serialisationError = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:"Serialization error"])
            done(nil,serialisationError)
            return
        }
        if let status = json?["status"] as? String {
            if status != "OK" {
                print("GooglePlaces API Error: \(status)")
                let error = NSError(domain: ErrorDomain, code: 1002, userInfo: [NSLocalizedDescriptionKey:status])
                done(nil,error)
                return
            }
        }
        done(json,nil)
    }
}
// MARK:- SearchPlaceVC (UITableViewDataSource / UITableViewDelegate)
extension SearchPlaceVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCustomCellIdentifier", for: indexPath) as! SearchPlaceCustomCell
        // Configure the cell
        let place = self.places[indexPath.row]
        cell.placeDescriptionLabel!.text = place.desc
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.places[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sid_PlaceDetailsVC") as! PlaceDetailsVC
        vc.placeId = place.id
        vc.placeAddress = place.desc
        self.searchTxtFld.text = ""
        self.searchTxtFld.resignFirstResponder()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32.0
    }
}
//MARK:- UITextField Delegate Method
extension SearchPlaceVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text == "") {
            self.places = []
            tableView.isHidden = true
        } else {
            let txt = textField.text!.replacingOccurrences(of: " ", with: "")
            getPlaces(searchString: txt)
        }
        return true
    }
}
