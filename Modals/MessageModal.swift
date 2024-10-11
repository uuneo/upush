//
//  MessageModal.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import Foundation
import RealmSwift


final class Message: Object , ObjectKeyIdentifiable, Codable {
	@Persisted var id:String = UUID().uuidString
	@Persisted var title:String?
	@Persisted var body:String?
	@Persisted var icon:String?
	@Persisted var group:String = String(localized: "默认")
	@Persisted var url:String?
	@Persisted var from:String?
	
	@Persisted var mode:String?
	@Persisted var createDate = Date()
	@Persisted var read:Bool = false
	
	override class func primaryKey() -> String? {
		return "id"
	}

	override class func indexedProperties() -> [String] {
		return ["group", "createDate", "from"]
	}
	
	enum CodingKeys: CodingKey {
		case id
		case title
		case body
		case icon
		case group
		case url
		case from
		case mode
		case createDate
		case read
	}
	
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.title, forKey: .title)
		try container.encode(self.body, forKey: .body)
		try container.encode(self.icon, forKey: .icon)
		try container.encode(self.group, forKey: .group)
		try container.encode(self.url, forKey: .url)
		try container.encode(self.from, forKey: .from)
		try container.encode(self.mode, forKey: .mode)
		try container.encode(self.createDate, forKey: .createDate)
		try container.encode(self.read, forKey: .read)
	}
	
	
}




extension Message{
   
		static let messages = [
		   
			Message(value: ["title":  String(localized: "示例"),"group":  String(localized: "示例"),"body": String(localized:  "点击或者滑动可以修改信息状态"),"icon":"warn","image":otherUrl.defaultImage,"cloud":true,"mode":"999"]),
			Message(value: ["group":  "App","title":String(localized: "点击跳转其他app") ,"body":String(localized:  "url属性可以打开URLScheme, 点击通知消息自动跳转，前台收到消息自动跳转"),"url":"weixin://","icon":"weixin","cloud":true,"mode":"999"])
		]
	
}


extension Message{
	
	func update(completion: @escaping (Message?) -> Void){
		do {
			let realm = try Realm()
			try realm.write {
				completion(realm.objects(Message.self).first(where: {$0 == self}))
			}
			
		}catch{
			completion(nil)
		}
	}
	
	func isRead(completion: ((String)-> Void)? = nil) {
		do {
			let realm = try Realm()
			try realm.write {
				if let data = realm.objects(Message.self).first(where: {$0 == self}){
					data.read = !data.read
					completion?(String(localized: "修改成功"))
				}else{
					completion?(String(localized: "没有数据"))
				}
				
			}
			
		}catch{
			completion?(error.localizedDescription)
		}
	}
	
	func delete(completion: ((String)-> Void)? = nil){
		do {
			let realm = try Realm()
			try realm.write {
				if let data = realm.objects(Message.self).first(where: {$0 == self}){
					data.read = !data.read
					completion?(String(localized: " 删除成功"))
				}else{
					completion?(String(localized: "没有数据"))
				}
			}
			
		}catch{
			completion?(error.localizedDescription)
		}
	}
	
}





extension ResultsSection: @retroactive Hashable{
	public func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
	
	
}
