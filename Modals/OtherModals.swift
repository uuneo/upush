//
//  Enums.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation




enum saveType:String{
    case failUrl
    case failSave
    case failAuth
    case success
    case other
	
	var localized: String {
		switch self {
		case .failUrl:
			return String(localized:"Url错误")
		case .failSave:
			return String(localized:"保存失败")
		case .failAuth:
			return String(localized: "没有权限")
		case .success:
			return String(localized: "保存成功")
		case .other:
			return String(localized:  "其他错误")
		}
	}
}



enum requestHeader :String {
    case https = "https://"
    case http = "http://"
}




struct Identifiers {
    static let reminderCategory = "myNotificationCategory"
    static let cancelAction = "cancel"
    static let copyAction = "copy"
    static let detailAction = "viewDetail"
}
