//
//  RealmProxy.swift
//  Pushup
//
//  Created by He Cho on 2024/10/9.
//
import SwiftUI
import RealmSwift


class RealmProxy{
	
	static let shared = RealmProxy()
	private init(){}
	
	
	
	private func realm(completion: @escaping (Realm) -> Void, fail: ((String)->Void)? = nil){
		do{
			let proxy = try Realm()
			
			try proxy.write {
				completion(proxy)
			}
			
		}catch{
			fail?(error.localizedDescription)
		}
	}
	
	func deleteByDate(date: Date){
		
		self.realm { proxy in
			let messages = proxy.objects(Message.self).where({ $0.createDate < date })
			for msg in messages{
				proxy.delete(msg)
			}
		}
		
	}
	
	func readAll(group: String? = nil){
		
		self.realm { proxy in
			let messages = proxy.objects(Message.self).filter({
				(msg) -> Bool in
				if let group = group{
					msg.group == group
				}else{
					true
				}
			})
			
			for msg in messages{
				msg.read = true
			}
		}
		
		
	}
	
	func deleteByGroup(group: String){
		
		self.realm { proxy in
			let messages = proxy.objects(Message.self).filter( {$0.group == group} )
			
			for msg in messages{
				proxy.delete(msg)
			}
		}
		
	}
	
	func update(message:Message ,completion: @escaping (Message?) -> Void){
		
		self.realm { proxy in
			completion(proxy.objects(Message.self).first(where: {$0 == message}))
		}
	}
	
	func isRead(message:Message ,completion: ((String)-> Void)? = nil) {
		self.realm { proxy in
			if let data = proxy.objects(Message.self).first(where: {$0 == message}){
				data.read = true
				completion?(String(localized: "修改成功"))
			}else{
				completion?(String(localized: "没有数据"))
			}
		}
		
	}
	
	func delete(message:Message ,completion: ((String)-> Void)? = nil){
		
		self.realm { proxy in
			if let data = proxy.objects(Message.self).first(where: {$0 == message}){
				data.read = !data.read
				completion?(String(localized: "删除成功"))
			}else{
				completion?(String(localized: "没有数据"))
			}
		}
	}

	
}
