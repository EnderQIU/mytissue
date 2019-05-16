//
//  ViewController.swift
//  mytissue
//
//  Created by enderqiu on 2018/11/8.
//  Copyright © 2018年 enderqiu. All rights reserved.
//

import UIKit
import WebKit
import UserNotifications


class GameViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    @IBOutlet weak var tissueWebKitView: WKWebView!
    
    let ooyodo = UserDefaults.standard.bool(forKey: "ooyodo")
    
    var ahead: Double = TimeInterval(UserDefaults.standard.string(forKey: "ahead")!)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        // Do any additional setup after loading the view, typically from a nib.
        let host = UserDefaults.standard.string(forKey: "host")!;
        let testMode = UserDefaults.standard.bool(forKey: "testMode");
        var testModeStr = "";
        if testMode { testModeStr = "&testMode=true" }
        let email = UserDefaults.standard.string(forKey: "email")!;
        let password = UserDefaults.standard.string(forKey: "password")!;
        let myURL = URL(string:host);
        var myRequest = URLRequest(url: myURL!);
        let postString = "login_id=" + email + "&password=" + password + "&mode=5" + testModeStr
        myRequest.httpBody = postString.data(using: .utf8)
        myRequest.httpMethod = "POST";
        myRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // register JS listener
        tissueWebKitView.configuration.userContentController.add(self, name: "timeIntervalNotificationTriggerHandler")
        
        // remove add delivered notifications
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        tissueWebKitView.load(myRequest);
    }
    
    @available(iOS 8.0, *)
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            case "timeIntervalNotificationTriggerHandler":
                if let dic = message.body as? NSDictionary {
                    let identifier: String = (dic["identifier"] as AnyObject).description
                    let title: String = (dic["title"] as AnyObject).description
                    let body: String = (dic["body"] as AnyObject).description
                    let soundName: String = (dic["soundName"] as AnyObject).description
                    
                    let interval: Double = TimeInterval((dic["interval"] as AnyObject).description)!
                    // Handle negative value
                    if (interval < 0){
                        print("Invalid interval.")
                        break
                    }
                    var _interval = interval - ahead
                    if (_interval <= 0){
                        _interval = interval
                    }
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = body
                    if (!ooyodo || soundName == "default" || soundName.isEmpty){
                        content.sound = UNNotificationSound.default
                    }else{
                        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))  // will be default sound if not exist
                    }

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: _interval, repeats: false)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                    // Schedule the notification.
                    let center = UNUserNotificationCenter.current()
                    center.add(request)
                    }
            default:
                print("JS called an unregistered handler.")
                break
        }
    }
    
    // We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let alert = UIAlertController(title: "Choose an action:", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Clear Caches", comment: "Default action"), style: .default, handler: { _ in
                URLCache.shared.removeAllCachedResponses()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Reload", comment: "Default action"), style: .default, handler: { _ in
                self.tissueWebKitView.reload()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Logout", comment: "Default action"), style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancle", comment: "Primary action"), style: .cancel, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

