//
//  PushServerInfo.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import Foundation
import Defaults
import SwiftUI

struct PushServerModal: Codable, Identifiable,Equatable, Defaults.Serializable{
	var id:String = UUID().uuidString
	var url:String
	var key:String
	var status:Bool = false
	
	var name:String{
		var name = url
		if let range = url.range(of: "://") {
		   name.removeSubrange(url.startIndex..<range.upperBound)
		}
		return name
	}
	
	var color: Color{
		status ? .green : .orange
	}
	
	enum CodingKeys: CodingKey {
		case id
		case url
		case key
		case status
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.url = try container.decode(String.self, forKey: .url)
		self.key = try container.decode(String.self, forKey: .key)
		self.status = try container.decode(Bool.self, forKey: .status)
	}
	
	init(url:String, key: String = "", statues:Bool = false){
		self.url = url
		self.key = key
		self.status = statues
	}
	
	static let serverDefault = PushServerModal(url: otherUrl.defaultServer, key: "")
	static let serverArr = [serverDefault]
  
}
