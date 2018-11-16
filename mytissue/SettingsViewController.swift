//
//  SettingsViewController.swift
//  mytissue
//
//  Created by enderqiu on 2018/11/8.
//  Copyright © 2018年 enderqiu. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var host: UITextField!
    @IBOutlet weak var testMode: UISwitch!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var grantButton: UIButton!
    @IBOutlet weak var ahead: UITextField!
    @IBOutlet weak var requireNumber: UILabel!
    @IBOutlet weak var invalidScheme: UILabel!
    @IBOutlet weak var foreground: UISwitch!
    @IBOutlet weak var version: UILabel!
    @IBAction func grantNotification(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (UNNotificationSettings) in
            if (UNNotificationSettings.authorizationStatus == UNAuthorizationStatus.notDetermined){
                center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                }
            }
            else if (UNNotificationSettings.authorizationStatus == UNAuthorizationStatus.authorized){
                let alertController = UIAlertController(title: "Notification has been allowed", message: "You have already allowed us send notifications to you.", preferredStyle: UIAlertController.Style.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                })
            }
            else{
                let alertController = UIAlertController(title: "Allow Notification", message: "Please go to [Settings - Notifocation] to allow us send notifications to you.", preferredStyle: UIAlertController.Style.alert)
                
                let openAction = UIAlertAction(title: "Open Settings", style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    if let url = URL(string: UIApplication.openSettingsURLString){
                        if (UIApplication.shared.canOpenURL(url)){
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                
                let okAction = UIAlertAction(title: "Not Now", style: UIAlertAction.Style.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                alertController.addAction(openAction)
                alertController.addAction(okAction)
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    @IBAction func update(_ sender: Any) {
        let url = URL(string: "https://github.com/EnderQIU/mytissue/releases")
        UIApplication.shared.open(url!)
    }
    @IBAction func help(_ sender: Any) {
        let url = URL(string: "https://ooi.enderqiu.cn/#ooi-announcement")
        UIApplication.shared.open(url!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        host.text = UserDefaults.standard.string(forKey: "host")
        testMode.isOn = UserDefaults.standard.bool(forKey: "testMode")
        foreground.isOn = UserDefaults.standard.bool(forKey: "foreground")
        email.text = UserDefaults.standard.string(forKey: "email")
        password.text = UserDefaults.standard.string(forKey: "password")
        ahead.text = UserDefaults.standard.string(forKey: "ahead")
        
        // Get version and build number
        let infoDictionary = Bundle.main.infoDictionary
        if let infoDictionary = infoDictionary {
            let appVersion = infoDictionary["CFBundleShortVersionString"]
            let appBuild = infoDictionary["CFBundleVersion"]
            version.text = "version \(appVersion ?? "nil") build \(appBuild ?? "nil")"
        }
        
        // check notification authorization status
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (UNNotificationSettings) in
            if (UNNotificationSettings.authorizationStatus == UNAuthorizationStatus.authorized){
                DispatchQueue.main.async(execute: {
                    self.grantButton.setTitle("Already Granted", for: .normal)
                    self.grantButton.isEnabled = false
                })
            }
        }
    }
    
    func saveSettings() -> Void {
        UserDefaults.standard.set(host.text, forKey: "host")
        UserDefaults.standard.set(testMode.isOn, forKey: "testMode")
        UserDefaults.standard.set(foreground.isOn, forKey: "foreground")
        UserDefaults.standard.set(email.text, forKey: "email")
        UserDefaults.standard.set(password.text, forKey: "password")
        UserDefaults.standard.set(ahead.text, forKey: "ahead")
    }

    @IBAction func save(_ sender: Any) {
        if (!checkSettings()){
            return
        }
        saveSettings()
        
        let sb = UIStoryboard(name:"Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(false)
    }
    
    func checkSettings() -> Bool {
        func isPurnInt(string: String) -> Bool {
            
            let scan: Scanner = Scanner(string: string)
            
            var val:Int = 0
            
            return scan.scanInt(&val) && scan.isAtEnd
            
        }
        if ((host.text?.isEmpty)! || (email.text?.isEmpty)! || (password.text?.isEmpty)!){
            // noti
            let attr = [NSAttributedString.Key.foregroundColor: UIColor.red]
            let attrStr = NSAttributedString(string: "This field is required", attributes: attr)
            host.attributedPlaceholder = attrStr
            email.attributedPlaceholder = attrStr
            password.attributedPlaceholder = attrStr
            return false
        }
        else if (!(host.text?.hasPrefix("https://"))! && !(host.text?.hasPrefix("http://"))!){
            invalidScheme.isHidden = false
            return false
        }
        else if (!(host.text?.hasPrefix("https://"))!){
            let alertController = UIAlertController(title: "HTTP Not Suggested", message: "Host should start with HTTPS to protect your information on the internet.", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
                (result : UIAlertAction) -> Void in
            }
            let anywayAction = UIAlertAction(title: "Use HTTP Anyway", style: UIAlertAction.Style.default) {
                (result : UIAlertAction) -> Void in
                self.saveSettings()
                let sb = UIStoryboard(name:"Main", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                DispatchQueue.main.async(execute: {
                    self.present(vc, animated: true, completion: nil)
                })
            }
            alertController.addAction(okAction)
            alertController.addAction(anywayAction)
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            })
            return false
        }
        else if (!isPurnInt(string: ahead.text!)){
            requireNumber.isHidden = false
            return false
        }
        else {
            return true
        }
    }
}
