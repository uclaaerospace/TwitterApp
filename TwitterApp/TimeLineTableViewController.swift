//
//  TimeLineTableViewController.swift
//  TwitterApp
//
//  Created by yoshihisa haruyama on 9/12/15.
//  Copyright (c) 2015 yoshihisa haruyama. All rights reserved.
//

import UIKit
import Social
import Accounts

class TimeLineTableViewController: UITableViewController {
    
    var twitterAccount:ACAccount?
    

    var dataArray:[[String:String]] = []
   
    

        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            loginTwitter();
        }
    
    
    //テーブルの件数を登録
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    //テーブルの内容を代入
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //セルを内部的にリサイクルしているのでこちらが必須になります。
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TimeLineTableViewCell
        
        //cell.textLabel?.text = dataArray[indexPath.row]["title"]
        if let title = dataArray[indexPath.row]["title"]{
            cell.tweetLabel.text = title
        }
        
        //if let urlString = dataArray[indexPath.row]["image"]{
            
        //cell.imageView?.sd_setImageWithURL(NSURL(string: urlString),placeholderImage: UIImage(named: "placeholder"))
            
        
        
        //        }
    
        return cell
    }
    
    @IBAction func tapTweetBtn(sender: UIBarButtonItem) {
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //CancelもしくはPostを押した際に呼ばれ、投稿画面を閉じる処理を行っています。
            vc.completionHandler = {(result:SLComposeViewControllerResult) -> () in
                vc.dismissViewControllerAnimated(true, completion:nil)
            }
            
            ////投稿画面の初期値設定
            //vc.setInitialText("初期テキストを設定できます。")
            //vc.addURL(NSURL(string:"シェアURLを設定できます。"))
            self.presentViewController(vc, animated: true, completion: nil)
            
        }else{
            let alert = UIAlertController(title: "エラー", message: "Twitterアカウントが登録されていません。設定アプリを開きますか？", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "はい", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                if let URL = NSURL(string: UIApplicationOpenSettingsURLString){
                    UIApplication.sharedApplication().openURL(URL)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "いいえ", style: UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    /*
    *   Twitterのアクセストークンを取得
    */
    
    private func loginTwitter(){
        
        //Twitterが登録されていないケース
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            return
        }
        
        let store = ACAccountStore();
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if granted == false{
                //アカウントは登録されているが認証が拒否されたケース
                return;
            }
            
            let accounts = store.accountsWithAccountType(type);
            
            if accounts.count == 0{
                return;
            }
            
            if let account = accounts[0] as? ACAccount{
                println("自分のアカウント名：「\(account.username)」\n")
                
                //アカウントをメモリに保持
                self.twitterAccount = account
                
                //タイムラインを取得する
                self.downloadTwitterTimeLine()

            }
        }
    }

    
    /*
    Twitterのタイムラインを取得する
    */
    
    private func downloadTwitterTimeLine(){
        
        //自分の投稿一覧は「user_timeline.json」で取得可能
        let URL = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: URL, parameters: nil)
        request.account = twitterAccount
        request.performRequestWithHandler { (responseData, responseURL, error) -> Void in
            
            if error != nil{
                return;
            }
            
            if let res = NSJSONSerialization.JSONObjectWithData(responseData, options: .AllowFragments, error: nil) as? [NSDictionary]{
                
                self.dataArray = []
                
                for entry in res{
                    
                    if let user = entry["user"] as? NSDictionary, let name = user["name"] as? String{
                        println("ユーザー名：「\(name)」")
                    }
                    
                    
                    if let text = entry["text"] as? String{
                        
                        self.dataArray.append(["title":text])
                        
                        //dataArrayの配列内に連想配列「"title" :text]
                        //self.dataArray.appned()
                        
                        println(text)
                    }
                    println("------------------------")
                }
                
                dispatch_async(dispatch_get_main_queue(),{() -> Void in
                self.tableView.reloadData()
                
            })
            
        }
        
    }
    
    
    
    }
}
