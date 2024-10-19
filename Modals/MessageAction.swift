//
//  MessageAction.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//
import Foundation
import SwiftUI

enum MessageAction: String, CaseIterable, Equatable{
	case markRead = "allMarkRead"
	case lastHour = "hourAgo"
	case lastDay = "dayAgo"
	case lastWeek = "weekAgo"
	case lastMonth = "monthAgo"
	case allTime = "allTime"
	case cancel = "cancel"
	
	var localized:String{
		switch self {
		case .markRead:
			String(localized: "全部已读")
		case .lastHour:
			String(localized: "一小时前")
		case .lastDay:
			String(localized: "一天前")
		case .lastWeek:
			String(localized: "一周前")
		case .lastMonth:
			String(localized: "一月前")
		case .allTime:
			String(localized: "所有时间")
		case .cancel:
			String(localized: "取消")
		}
	}
	
	var date:Date{

		switch self {
		case .lastHour:
			Date().someHourBefore(1)
		case .lastDay:
			Date().someDayBefore(0)
		case .lastWeek:
			Date().someDayBefore(7)
		case .lastMonth:
			Date().someDayBefore(30)
		case .allTime:
			Date()
		default:
			Date().s1970
		}
	}
	
}


