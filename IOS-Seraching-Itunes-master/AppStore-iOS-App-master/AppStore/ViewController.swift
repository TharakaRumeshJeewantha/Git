//
//  ViewController.swift
//  AppStore
//
//  Created by Tharaka R Jeewantha on 10/2/18.
//  Copyright © 2018 Tharaka R Jeewantha. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNoResponse: UILabel!
    @IBOutlet var lblSellerName: UILabel!
    @IBOutlet var lblType: UILabel!
    @IBOutlet var lblGener: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    
    @IBAction func closeAction(_ sender: Any) {
        self.popupView.removeFromSuperview()
    }
    //to setup table
    var appArray = [iOSApps]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        alterLayout()
        table.tableFooterView = UIView()
        self.lblNoResponse.text = "Enter search key word"
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.popupView.addGestureRecognizer(gesture)
    }

    
    //setup search bar
    private func setUpSearchBar(){
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        print(searchBar)
        
        if searchBar.text == nil || searchBar.text == "" {
            print("No search key word")
            self.lblNoResponse.text = "Enter search key word"
            self.lblNoResponse.alpha = 1
            self.appArray.removeAll()
            self.table.reloadData()
        }
        else{
            setUpApps(key: searchBar.text!)
        }
    }
    
    //set values to array
    private func setUpApps(key: String) {
        appArray.removeAll()
        self.table.reloadData()
        let formattedKey =  key.replacingOccurrences(of: " ", with: "+")
        
        let url=URL(string:"https://itunes.apple.com/search?term="+formattedKey+"&limit=50&entity=software")
        do {
            let receivedData = try Data(contentsOf: url!)
            let responseJSON = try JSONSerialization.jsonObject(with: receivedData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
            if let resultCount = responseJSON["resultCount"] as? Int {
                if resultCount > 0 {
                    if let results = responseJSON["results"] as? [[String: AnyObject]] {
                        for index in 0...results.count-1 {
                            
                            let result = results[index]
                            
                            let formattedPrice = result["formattedPrice"] as? String ?? "Free"
                            var dispayPrice : String
                            if formattedPrice == "Free" {
                                dispayPrice = "Free"
                            }
                            else{
                                dispayPrice = String(result["formattedPrice"] as! String)
                            }
                            
                            appArray.append(
                                iOSApps(name: result["trackName"] as! String, sellerName: result["sellerName"] as! String, price: dispayPrice, type: result["kind"] as! String, gener: result["primaryGenreName"] as! String, image: result["artworkUrl60"] as! String))
                        }
                        
                        if self.appArray.count > 0 {
                            self.lblNoResponse.alpha = 0
                            table.reloadData()
                            let indexPath = IndexPath(row: 0, section: 0)
                            table.scrollToRow(at: indexPath, at: .top, animated: true)
                            searchBar.text = "";
                        }
                        else {
                            self.lblNoResponse.text = "Result not found"
                            self.lblNoResponse.alpha = 1
                            print("array empty")
                        }
                    }
                }
                else {
                    self.lblNoResponse.text = "Result not found"
                    self.lblNoResponse.alpha = 1
                    print("no result")
                }
            }
            else {
                self.lblNoResponse.text = "Result not found"
                self.lblNoResponse.alpha = 1
                print("dictonary problem")
            }
           
        }
        catch {
            self.lblNoResponse.alpha = 1
            print("Error")
        }
        self.searchBar.endEditing(true)
    }
    
    func alterLayout(){
        table.tableHeaderView = UIView()
        table.estimatedSectionHeaderHeight = 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appArray.count
    }
    
    //set values to table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableCell else {
            return UITableViewCell()
        }
        //cell.selectionStyle = .none
        cell.name.text = appArray[indexPath.row].name
        cell.sellerName.text = appArray[indexPath.row].sellerName
        cell.price.text = "   " + appArray[indexPath.row].price + "   "
        
        
        //download and set image
        let url = NSURL(string:self.appArray[indexPath.row].image)
        let imagedata = NSData.init(contentsOf: url! as URL)
        
        if imagedata != nil {
            cell.imgView.image = UIImage(data:imagedata! as Data)
        }
        return cell
    }
    
    
    // select a cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let url = NSURL(string:self.appArray[indexPath.row].image)
        let imagedata = NSData.init(contentsOf: url! as URL)
        
        if imagedata != nil {
            self.imgProfile.image = UIImage(data:imagedata! as Data)
        }
        else {
            print("No image found")
        }
        
        self.popupView.layer.cornerRadius = 5
        self.popupView.layer.borderWidth = 1
        self.popupView.layer.borderColor = UIColor.gray.cgColor
        
        self.popupView.layer.shadowColor = UIColor.black.cgColor
        self.popupView.layer.shadowOpacity = 1
        self.popupView.layer.shadowOffset = CGSize.zero
        self.popupView.layer.shadowRadius = 100
        
        self.lblName.text = self.appArray[indexPath.row].name
        self.lblSellerName.text = self.appArray[indexPath.row].sellerName
        self.lblType.text = "Type: " + self.appArray[indexPath.row].type
        self.lblGener.text = "Gener: " + self.appArray[indexPath.row].gener
        
        self.lblPrice.layer.cornerRadius = 5
        self.lblPrice.text = "   " + self.appArray[indexPath.row].price + "   "
        
        self.view.addSubview(self.popupView)
        self.popupView.center = self.view.center
        self.popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

    }
    
    @objc func checkAction(){
        self.popupView.removeFromSuperview()
    }
    
        
    //set table hight
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //set search bar on top
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return searchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}

class iOSApps {
    let name: String
    let sellerName: String
    let price: String
    let type: String
    let gener: String
    let image: String
    
    init(name: String, sellerName: String, price: String, type: String, gener: String, image: String) {
        self.name = name
        self.sellerName = sellerName
        self.price = price
        self.type = type
        self.gener = gener
        self.image = image
    }
}

