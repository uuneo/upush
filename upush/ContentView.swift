//
//  ContentView.swift
//  upush
//
//  Created by He Cho on 2024/10/11.
//

import SwiftUI
import RealmSwift
import Defaults

struct ContentView: View {
	
	@Environment(\.scenePhase) var scenePhase
	@Environment(PushupManager.self) private var manager
	@StateObject private var monitor = Monitors()
	@ObservedResults(Message.self) var messages
	@Default(.servers) var servers
	@Default(.firstStart) var firstStart
	@State private var noShow:NavigationSplitViewVisibility = .detailOnly
	@State private  var showAlart:Bool = false
	@State private  var activeName:String = ""
	@State private var messagesPath: [String] = []
	

	
	var readCount:Int{
		messages.where({!$0.read}).count
	}
	
	var body: some View {
		
		ZStack{
			if ISPAD{
				IpadHomeView()
			}else{
				IphoneHomeView()
			}
		}
		.dropDestination(for: Data.self) { items, location in
			Task.detached(priority: .background) {
				for item in items {
					await ImageManager.storeImage(data: item, key: UUID().uuidString)
				}
				Toast.shared.present(title: String(localized: "保存成功"), symbol: "photo.badge.checkmark")
			}
			return true
		}
		.sheet(isPresented: manager.sheetShow){ ContentSheetViewPage() }
		.fullScreenCover(isPresented: manager.fullShow){ ContentFullViewPage() }
		.onChange(of: scenePhase, self.backgroundModeHandler)
		.onOpenURL(perform: self.openUrlView)
		.alert(isPresented: $showAlart) {
			Alert(title:
					Text(String(localized: "操作不可逆!")),
				  message:
					Text( activeName == "alldelnotread" ?
						  String(localized: "是否确认删除所有未读消息!") : String(localized: "是否确认删除所有已读消息!")
						),
				  primaryButton:
					.destructive(
						Text( String(localized: "删除") ),
						action: {
							
							//							realm.delete(read: activeName == "alldelnotread")
							
						}
					), secondaryButton: .cancel())
		}
		.onAppear{
			if firstStart {
				for msg in Message.messages{
					$messages.append(msg)
				}
				self.firstStart = false
			}
		}
		

		
	}
	
	
	@ViewBuilder
	func IphoneHomeView()-> some View{
		TabView(selection: Binding(get: {
			manager.page
		}, set: { value in
			manager.page = value
		})) {
			
			// MARK: 信息页面
			
			MessagesView()
				.tag(TabPage.message)
				.badge(readCount)
				.tabItem {
					Label(String(localized: "消息"), systemImage: "ellipsis.message")
				}
			
			// MARK: 设置页面
			
			SettingsView()
				.tabItem {
					Label(String(localized: "设置"), systemImage: "gearshape")
					
				}
				.tag(TabPage.setting)
			
			
		}
	}
	
	@ViewBuilder
	func IpadHomeView() -> some View{
		NavigationSplitView(columnVisibility: $noShow) {
			SettingsView()
				.navigationTitle(String(localized: "设置"))
		} detail: {
			NavigationStack{
				MessagesView()
					.navigationTitle(String(localized: "消息"))
				
			}
		}
		
	}
	
	
	@ViewBuilder
	func ContentFullViewPage() -> some View{
		
		switch manager.fullPage {
		case .login:
			ChangePushKeyView()
				.onAppear{
					DispatchQueue.main.asyncAfter(deadline: .now() + 1){
						manager.fullPage = .none
					}
					
				}
		case .servers:
			ServersConfigView(showClose: true)
		case .music:
			RingtongView()
		case .scan:
			ScanView { code in
				manager.appendServer(server: PushServerModal(url: code)) { server, msg in
					
					Toast.shared.present(title: msg, symbol: "document.viewfinder")
				}
				
			}
		case .web:
			SFSafariView(url: manager.webUrl)
				.ignoresSafeArea()
		case .issues:
			SFSafariView(url: manager.webUrl)
				.ignoresSafeArea()
		default:
			EmptyView()
				.onAppear{
					DispatchQueue.main.asyncAfter(deadline: .now() + 1){
						manager.fullPage = .none
					}
				}
		}
	}
	
	@ViewBuilder
	func ContentSheetViewPage() -> some View {
		switch manager.sheetPage {
		case .servers:
			ServersConfigView(showClose: true)
		case .appIcon:
			NavigationStack{
				AppIconView()
			}.presentationDetents([.medium])
		case .web:
			SFSafariView(url: manager.webUrl)
				.ignoresSafeArea()
		default:
			EmptyView()
				.onAppear{
					manager.sheetPage = .none
				}
		}
	}
}

extension ContentView{
	
	func openUrlView(url: URL){
		guard let scheme = url.scheme,
			  let host = url.host(),
			  let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else{ return }
		
		let params = components.getParams()
#if DEBUG
		debugPrint(scheme, host, params)
#endif
		
		
		if host == "login"{
			if let url = params["url"]{
				
				manager.scanUrl = url
				manager.fullPage = .login
				
			}else{
				Toast.shared.present(title: String(localized: "参数错误"), symbol: "questionmark.circle.dashed")
			}
			
		}else if host == "add"{
			if let url = params["url"]{
				
				servers.append(PushServerModal(url: url))
				
				if !manager.showServerListView {
					manager.fullPage = .none
					manager.sheetPage = .none
					manager.page = .setting
					manager.showServerListView = true
				}
			}else{
				Toast.shared.present(title: String(localized: "参数错误"), symbol: "questionmark.circle.dashed")
			}
		}
	}
	
	
	
	
	func backgroundModeHandler(oldValue:ScenePhase, newValue: ScenePhase){
		switch newValue{
		case .active:
#if DEBUG
			print("app active")
#endif
			stopCallNotificationProcessor()
			
			if let name = QuickAction.selectAction?.userInfo?["name"] as? String{
				QuickAction.selectAction = nil
#if DEBUG
				print(name)
#endif
				manager.page = .message
				switch name{
				case "allread":
//					realm.readMessage()
					Toast.shared.present(title: String(localized: "操作成功"), symbol: "questionmark.circle.dashed")
				case "alldelread","alldelnotread":
					self.activeName = name
					self.showAlart.toggle()
				default:
					break
				}
			}
			
			HapticsManager.shared.restartEngine()
			manager.registers()
		case .background:
			manager.addQuickActions()
			HapticsManager.shared.stopEngine()
			firstStart = false
			
		default:
			
			break
			
			
		}
		
		//		let toolManager = ToolsManager.shared
		//
		//		if toolManager.badgeMode == .auto{
		//			toolManager.changeBadge(badge: realm.NReadCount())
		//		}else{
		//			toolManager.changeBadge(badge: -1)
		//		}
			
	}
	
	/// 停止响铃
	func stopCallNotificationProcessor() {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(BaseConfig.kStopCallProcessorKey as CFString), nil, nil, true)
	}
	

}

#Preview {
	ContentView()
		.environment(PushupManager.shared)
}
