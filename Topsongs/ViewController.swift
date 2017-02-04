//
//  ViewController.swift
//  Topsongs
//
//  Created by Nguyen Bach on 2/1/17.
//  Copyright © 2017 Nguyen Bach. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
  final let urlString = "https://itunes.apple.com/us/rss/topsongs/limit=50/genre=1/explicit=true/json"
    final let urlStringBasement = "http://is4.mzstatic.com/"
    var TableData:Array< dataImgStruct> = Array <dataImgStruct>()
    
    struct dataImgStruct {
        var nameSongArray :String?
        var authorArray : String?
        var imgURLArray : String?
        var price : String?
        
         var imgTable:UIImage? = nil
//        init(add: Dictionary<String, Any>) {
//            imgURLArray = add["im:image"] as? String
//        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
 //       self.downloadJsonWithURL()
        self.downloadJsonWithTask(data: urlString)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        return nameSongArray.count
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.songNames.text = TableData[indexPath.row].nameSongArray
        cell.author.text = TableData[indexPath.row].authorArray
        cell.buttonPrice.setTitle(TableData[indexPath.row].price, for: .normal)
        cell.buttonPrice.layer.cornerRadius = 15
        cell.buttonPrice.layer.masksToBounds = true
        if (cell.imageSongs.image == nil){
            cell.imageSongs.image = UIImage(named: "imageNotFound.jpg")
            loadingImage(urlString:urlStringBasement + TableData[indexPath.row].imgURLArray! , imageview: cell.imageSongs, index: indexPath.row)
            
        }else{
            cell.imageSongs.image = TableData[indexPath.row].imgTable
            
        }
      
        return cell
    }
    func downloadJsonWithURL(data: NSString)  {
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: (url as? URL)!, completionHandler:{
            (data, response, error) -> Void in
           // print(data)
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! Dictionary<String, Any>{
                if let feed = jsonObj["feed"] as? Dictionary<String, Any>{
                    if let entries = feed["entry"] as? [Dictionary<String, Any>]{
                        for entry in entries{

                            let imName = entry["im:name"] as? Dictionary<String, Any>
                            let name = imName?["label"] as! String

                            
                            let imArtist = entry["im:artist"] as? Dictionary<String,Any>
                            let artitstName = imArtist?["label"] as! String

                            let imImage = entry["im:image"] as? Array<Dictionary<String, Any>>
//                            let imageUrl = imImage?["label"] as! String
                            let imageUrl = imImage?[2]["label"] as! String

                            let imPrice = entry["im:price"] as? Dictionary<String, Any>
                            let price = imPrice?["label"] as! String

                            self.TableData.append(dataImgStruct(nameSongArray: name, authorArray: artitstName, imgURLArray: imageUrl, price: price, imgTable: nil))
                            OperationQueue.main.addOperation({
                                self.read()
                                self.tableView.reloadData()
                            })
                            
                        }
                    }
                }
            }
        }).resume()
    }
    func  downloadJsonWithTask(data:String)  {
        let url = NSURL(string: urlString)
        var downloadTask = URLRequest(url: (url as? URL)!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        downloadTask.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: downloadTask, completionHandler:{
            (data, response, error) -> () in
       
            if (data?.count)! > 0 && error == nil{
                let json = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)
                self.downloadJsonWithURL(data: json!)
            }else if data?.count == 0 && error == nil{
                print("Nothing was downloaded")
            }else if error != nil{
                print("Error happened = \(error)")
            }
        }).resume()
    }
    
    func loadingImage(urlString: String, imageview:UIImageView, index: NSInteger)  {
        let imgURL : NSURL = NSURL(string: urlString)!
         let request = URLRequest(url: (imgURL as URL), cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        URLSession.shared.dataTask(with: request, completionHandler:{
            (data, response, error) -> Void in
                if error == nil {
                   self.TableData[index].imgTable = UIImage(data: data!)!
                    self.save(id: index, image: self.TableData[index].imgTable!)
                    
                    imageview.image = self.TableData[index].imgTable!
                    
                }
        })
        
    }
    
    func read(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchrequest: NSFetchRequest<Images> = Images.fetchRequest()
     
        do{
        let fetchedresults = try managedContext.fetch(fetchrequest)
            for i in 0..<fetchedresults.count{
                let single_result = fetchedresults[i]
                let index = single_result.value(forKey: "index") as! NSInteger
                let img: NSData? = single_result.value(forKey: "iamges") as? NSData
                TableData[index].imgTable = UIImage(data: img! as Data)!
            }
        }catch{
            print("Error occured duting execution :\(error)")
        }
        
    }
    func save(id:Int,image:UIImage)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Images", in: managedContext)
        let options = NSManagedObject(entity: entity!, insertInto: managedContext)
        let newImageData = UIImageJPEGRepresentation(image, 1)
        options.setValue(id, forKey: "index")
        options.setValue(newImageData, forKey: "images")
        do{
        try managedContext.save()
       
        }catch{
            print("WrongHole: \(error)")
        }
    }
}

