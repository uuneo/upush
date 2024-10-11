//
//  QuickActionModal.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//
import Foundation
import UIKit

enum QuickAction{
	static var selectAction:UIApplicationShortcutItem?
	
	static var allReaduserInfo:[String: NSSecureCoding]{
		["name":"allread" as NSSecureCoding]
	}
	
	static var allDelReaduserInfo:[String: NSSecureCoding]{
		["name":"alldelread" as NSSecureCoding]
	}
	
	static var allDelNotReaduserInfo:[String: NSSecureCoding]{
		["name":"alldelnotread" as NSSecureCoding]
	}
	
	static var allShortcutItems = [
		UIApplicationShortcutItem(
			type: "allread",
			localizedTitle: String(localized:  "已读全部") ,
			localizedSubtitle: "",
			icon: UIApplicationShortcutIcon(systemImageName: "bookmark"),
			userInfo: allReaduserInfo
		),
		UIApplicationShortcutItem(
			type: "alldelread",
			localizedTitle: String(localized: "删除全部已读"),
			localizedSubtitle: "",
			icon: UIApplicationShortcutIcon(systemImageName: "trash"),
			userInfo: allDelReaduserInfo
		),
		UIApplicationShortcutItem(
			type: "alldelnotread",
			localizedTitle: String(localized:  "删除全部未读"),
			localizedSubtitle: "",
			icon: UIApplicationShortcutIcon(systemImageName: "trash"),
			userInfo: allDelNotReaduserInfo
		)
	]
}
