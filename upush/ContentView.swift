//
//  ContentView.swift
//  upush
//
//  Created by He Cho on 2024/10/11.
//

import SwiftUI
import RealmSwift
import Defaults
import UniformTypeIdentifiers

struct ContentView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.scenePhase) private var scenePhase
	@Environment(UpushManager.self) private var manager
	@StateObject private var monitor = Monitors()
	@ObservedResults(Message.self) private var messages
	@Default(.servers) private var servers
	@Default(.firstStart) private var firstStart
	@Default(.badgeMode) private var badgeMode
	@State private var noShow:NavigationSplitViewVisibility = .detailOnly
	@State private  var showAlart:Bool = false
	@State private  var activeName:String = ""
	@State private var messagesPath: [String] = []
	@Environment(\.modelContext) private var ctx
	
	var readCount:Int{
		messages.where({!$0.read}).count
	}
	
	var tabColor2:Color{
		colorScheme == .dark ? Color.white : Color.black
	}
	
	var body: some View {
		
		ZStack{
			if ISPAD{
				IpadHomeView()
			}else{
				IphoneHomeView()
			}
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
							RealmProxy.shared.read(activeName == "alldelnotread")
						}
					), secondaryButton: .cancel())
		}
		.onAppear{
			if firstStart {
				for msg in Message.messages{
					if let realm = try? Realm(){
						try? realm.write {
							realm.add(msg)
						}
					}
				}
				self.firstStart = false
			}
			
			iCloudManager.ceshi()
			
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
			
			GroupMessageView()
				.badge(readCount)
				.tabItem {
					Label(String(localized: "消息"), systemImage: "ellipsis.message")
						.symbolRenderingMode(.palette)
						.foregroundStyle( .green, tabColor2)
//						.symbolEffect(.variableColor.cumulative.dimInactiveLayers.reversing, options: .repeat(.continuous))
				}
				.tag(TabPage.message)
			
			// MARK: 设置页面
			
			SettingsView()
				.tabItem {
					Label(String(localized: "设置"), systemImage: "gear.badge.questionmark")
						.symbolRenderingMode(.palette)
						.foregroundStyle( .green, tabColor2)
//						.symbolEffect(.pulse.byLayer, options: .repeat(.continuous))
					
				}
				.tag(TabPage.setting)
			
			
		}
		
	}
	
	@ViewBuilder
	func IpadHomeView() -> some View{
		NavigationSplitView(columnVisibility: $noShow) {
			SettingsView()
				
		} detail: {
			GroupMessageView()
		}
		
	}
	
	
	@ViewBuilder
	func ContentFullViewPage() -> some View{
		
		switch manager.fullPage {
		case .login:
			ChangeKeyWithEmailView()
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
			
			stopCallNotificationProcessor()
			if let name = QuickAction.selectAction?.userInfo?["name"] as? String{
				QuickAction.selectAction = nil
				manager.page = .message
				switch name{
				case "allread":
					RealmProxy.shared.read()
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
		RealmProxy.ChangeBadge()
	}
	
	/// 停止响铃
	func stopCallNotificationProcessor() {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(BaseConfig.kStopCallProcessorKey as CFString), nil, nil, true)
	}
	

}

#Preview {
	ContentView()
		.environment(UpushManager.shared)
}
