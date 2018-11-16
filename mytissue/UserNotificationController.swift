//
//  UserNotificationController.swift
//  mytissue
//
//  Created by enderqiu on 2018/11/16.
//  Copyright © 2018年 enderqiu. All rights reserved.
//

import UIKit
import UserNotifications

class UserNotificationController: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = UserNotificationController()
    
    // app is in foreground when a notification arrived
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler(UNNotificationPresentationOptions.alert)
    }
}
