//
//  PushupManager.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import Defaults

@Observable
class PushupManager{
	static let shared = PushupManager()
	
	private init() {}
	
	private let session = URLSession(configuration: .default)

	var page:TabPage = .message
	var sheetPage:SubPage = .none
	var fullPage:SubPage = .none
	var webUrl:String = ""
	var scanUrl:String = ""
	var showServerListView:Bool = false
	
	var fullShow:Binding<Bool>{
	
		Binding {
			self.fullPage != .none
		} set: { value in
			if !value {
				self.fullPage = .none
			}
		}
	}
	
	var sheetShow:Binding<Bool>{
		Binding {
			self.sheetPage != .none
		} set: { value in
			if !value {
				self.sheetPage = .none
			}
		}
		
	}
	
}

extension PushupManager{
	/// 请求服务器数据
	func fetch<T:Codable>(url:String) async throws -> T?{
		guard let requestUrl = URL(string: url) else {return  nil}
		let data = try await session.data(for: URLRequest(url: requestUrl))
		let result = try JSONDecoder().decode(T.self, from: data)
		return result
	}
}
 
extension PushupManager{
	
	/// 更新服务器的状态
	///  - Parameters:
	///  	- completion: (  url, success, message ) - > void
	func health(url: String) async -> (String, Bool, String?) {
		let healthUrl = otherUrl.defaultServer + "/health"
		do{
			let response:String? = try await self.fetch(url: healthUrl)
			let success = response == "ok"
			await MainActor.run {
				if 	let index = Defaults[.servers].firstIndex(where: {$0.url  == url}){
					Defaults[.servers][index].status = success
				}
			}
			return (url,success, "")
		}catch{
			return (url,false, error.localizedDescription)
		}
	}
	/// 更新所有的服务器的状态
	///  - Parameters:
	///  	- completion: [(  url: 网址, bool: 是否成功, string: 提示消息 )]- > void
	func healths(completion: (([(String, Bool, String?)])-> Void)? = nil){
		Task.detached(priority: .background) {
			await withTaskGroup(of:(String, Bool, String?).self){ group in
				for server in Defaults[.servers] {
					group.addTask{  await self.health(url: server.url)  }
				}
				
				var results:[(String, Bool, String?)] = []
				
				for await result in group{
					results.append(result)
				}
				completion?(results)
			}
			
		}
	}
	
	/// 更新所有的服务器的状态
	///  - Parameters:
	///  server: 服务器数据
	///  completion: 服务器数据，提示消息
	func register(server: PushServerModal, completion: ((PushServerModal,String)-> Void)? = nil){
		Task.detached(priority: .high) {
			let (server1,msg) = await self.register(server: server)
			completion?(server1, msg)
		}
	}
	
	/// 更新所有的服务器的状态
	///  - Parameters:
	///  server: 服务器数据
	///  completion: 列表 ( 服务器数据，提示消息 )
	func registers(completion: (([(PushServerModal,String)])-> Void)? = nil){
		Task.detached(priority: .background) {
		
			await withTaskGroup(of: (PushServerModal,String).self) { group in
				for server in Defaults[.servers] {
					group.addTask {await self.register(server: server)}
				}
				
				var results:[(PushServerModal,String)] = []
				for await result in group{
					results.append(result)
				}
				completion?(results)
			}
		}
	}
	
	func register(server: PushServerModal) async -> (PushServerModal,String){
		
		do{
			let deviceToken = Defaults[.deviceToken]
			if let index = Defaults[.servers].firstIndex(of: server){
				let url = server.url + "/register/" + deviceToken + "/" + server.key
				
				let response:baseResponse<DeviceInfo>? = try await self.fetch(url: url)
				if let response = response,
				   let data = response.data
				{
					DispatchQueue.main.async{
						Defaults[.servers][index].key = data.deviceKey
					}
					return (server,"注册成功")
				}
				
				
			}
			
		}catch{
			print(error.localizedDescription)
			return (server,error.localizedDescription)
		}
		
		return (server,"注册失败")
	}
	
	func appendServer(server:PushServerModal, completion: @escaping (PushServerModal,String)-> Void ){
		Task.detached(priority: .background) {
			let (_, success, msg) = await self.health(url: server.url)
			if success {
				await MainActor.run {
					Defaults[.servers].insert(server, at: 0)
				}
				let (serverresult,msg) = await self.register(server: server)
				completion(serverresult,msg)
			}else{
				completion(server ,msg ?? "")
			}
		}
	}
	
}



extension PushupManager{
	/// 复制信息到剪贴板
	func copy(_ text:String){
		UIPasteboard.general.string = text
	}
	
	/// 增加按住applogo显示快捷菜单
	func addQuickActions(){
		UIApplication.shared.shortcutItems = QuickAction.allShortcutItems
	}
	
	/// 打开app设置
	func openSetting(){
		guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
			return
		}
		
		UIApplication.shared.open(settingsURL)
	}

	
	
	func openUrl(url: URL, unOpen: ((URL)->Void)?) {
		if url.path().isValidURL() != .remote{
			UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true]) { success in
				if !success {
					unOpen?(url)
				}
			}
		}
		else {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
   
}
