//
//  SettingsView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//


import SwiftUI
import RealmSwift
import Combine
import Defaults

struct SettingsView: View {
	
	
	@Environment(PushupManager.self) private var manager
	@ObservedResults(Message.self) var messages
	@Default(.appIcon) var setting_active_app_icon
	@Default(.isMessageStorage) var  isMessageStorage
	@Default(.badgeMode) var badgeMode
	@Default(.sound) var sound
	@Default(.deviceToken) var deviceToken
	@Default(.servers) var servers

	@State private var webShow:Bool = false
	@State private var webUrl:String = otherUrl.helpWebUrl
	@State private var isShareSheetPresented = false
	@State private var jsonFileUrl:URL?

	@State private var showLoading:Bool = false
	
	@State private var showServerListView:Bool = false

	
	var serverTypeColor:Color{
		servers.allSatisfy({$0.status}) ? .green : .orange
	}
	
	
	var body: some View {
		NavigationStack{
			VStack{
				List{
					
					if ISPAD{
						NavigationLink{
							MessagesView()
								.navigationTitle(String(localized:  "消息"))
						}label: {
							Label(String(localized:  "消息"), systemImage: "app.badge")
						}
						
					}
					
					
					Section(header:Text(String(localized: "导出消息列表"))) {
						Button{
							self.exportFile()
						}label:{
							HStack{
								Label(String(localized: "导出"), systemImage: "square.and.arrow.up.circle")
								
								Spacer()
								Text(String(format: String(localized:"%d条消息"), messages.count) )
							}
						}
						
						
					}
					
					
					
					Section(footer:Text(String(localized:  "苹果设备推送Token,不要外泄"))) {
						Button{
							if deviceToken != ""{
								manager.copy(deviceToken)
								
								Toast.shared.present(title: String(localized: "复制成功"), symbol: "checkmark.arrow.trianglehead.counterclockwise")
								
							}else{
								
								Toast.shared.present(title:  String(localized: "请先注册"), symbol: "questionmark.circle.dashed")
							}
						}label: {
							HStack{
								
								Label {
									Text(String(localized: "令牌"))
										.font(.system(size: 15))
										.lineLimit(1)
										.foregroundStyle(.lightDark)
								} icon: {
									Image(systemName: "key.radiowaves.forward")
										.scaleEffect(0.9)
								}
								
								
								Spacer()
								Text(maskString(deviceToken))
									.foregroundStyle(.gray)
								Image(systemName: "doc.on.doc")
									.scaleEffect(0.9)
							}
						}
					}
					
					Section {
						Toggle(isOn: $isMessageStorage) {
							Text(String(localized:  "默认保存"))
						}
					}footer:{
						Text(String(localized: "当推送请求URL没有指定 isArchive 参数时，将按照此设置来决定是否保存通知消息"))
							.foregroundStyle(.gray)
					}
					
					
					
					
					Section {
						
						NavigationLink {
							ImageCacheView()
								.toolbar(.hidden, for: .tabBar)
								.navigationTitle(String(localized:  "历史图片"))
							
						} label: {
							Label(String(localized: "历史图片"), systemImage: "photo.on.rectangle")
						}
						
						
					}header :{
						Text(String(localized:  "历史图片"))
							.foregroundStyle(.gray)
					}
					
					
					
					
					
					Section(header: Text(String(localized:  "配置"))) {
						Button{
							manager.sheetPage = .appIcon
						}label: {
							
							
							HStack(alignment:.center){
								Label {
									Text(String(localized:"程序图标"))
										.foregroundStyle(.lightDark)
								} icon: {
									Image(setting_active_app_icon.logo)
										.resizable()
										.scaledToFit()
										.frame(width: 25)
										.clipShape(RoundedRectangle(cornerRadius: 10))
										.scaleEffect(0.9)
								}
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundStyle(.gray)
							}
							
						}
						
						
						Picker(selection: $badgeMode) {
							Text(String(localized: "自动")).tag(BadgeAutoMode.auto)
							Text(String(localized: "自定义")).tag(BadgeAutoMode.custom)
						} label: {
							Label {
								Text(String(localized: "角标模式"))
							} icon: {
								Image(systemName: "app.badge")
									.scaleEffect(0.9)
							}
						}
						
						.task{
							// MARK: - 修改badge的值
							for await value in Defaults.updates(.badgeMode) {
								print("Value:", value)
							}
						}
						
						
						
						//					NavigationLink(destination:
						//									EmailPageView() .toolbar(.hidden, for: .tabBar)
						//					) {
						//
						//						Label {
						//							Text(String(localized:"mailTitle", comment: "自动化配置"))
						//						} icon: {
						//							Image(systemName: "paperclip")
						//								.scaleEffect(0.9)
						//						}
						//					}
						//
						
						NavigationLink(destination:
										CryptoConfigView()
							.toolbar(.hidden, for: .tabBar)
						) {
							
							
							Label {
								Text(String(localized: "算法配置") )
							} icon: {
								Image(systemName: "bolt.shield")
									.scaleEffect(0.9)
							}
						}
						
						NavigationLink{
							RingtongView()
						}label: {
							
							HStack{
								Label {
									Text(String(localized: "铃声列表") )
								} icon: {
									Image(systemName: "headphones.circle")
										.scaleEffect(0.9)
								}
								Spacer()
								Text(sound)
									.scaleEffect(0.9)
									.foregroundStyle(.gray)
							}
						}
						
						
					}
					
					
					Section(header:Text( String(localized: "其他" ) )) {
						
						
						Button{
							manager.openSetting()
						}label: {
							HStack(alignment:.center){
								
								Label {
									Text(String(localized:  "打开设置"))
										.foregroundStyle(.lightDark)
								} icon: {
									Image(systemName: "gearshape")
										.scaleEffect(0.9)
									
								}
								
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundStyle(.gray)
							}
							
						}
						
						Button{
							manager.fullPage = .web
							manager.webUrl =  otherUrl.problemWebUrl
							
						}label: {
							HStack(alignment:.center){
								Label {
									Text(String(localized:  "常见问题"))
										.foregroundStyle(.lightDark)
								} icon: {
									Image(systemName: "questionmark.circle")
										.scaleEffect(0.9)
								}
								
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundStyle(.gray)
							}
							
						}
						
						Button{
							manager.webUrl = otherUrl.helpWebUrl
							manager.fullPage = .web
							
						}label: {
							HStack(alignment:.center){
								Label {
									Text(String(localized: "使用帮助"))
										.foregroundStyle(.lightDark)
								} icon: {
									Image(systemName: "person.crop.circle.badge.questionmark")
										.scaleEffect(0.9)
								}
								
								Spacer()
								Image(systemName: "chevron.right")
									.foregroundStyle(.gray)
							}
							
							
						}
						
						
					}
					
					
				}.listStyle(.insetGrouped)
				
				
			}
			.navigationTitle(String(localized: "设置"))
			.loading(showLoading)
			.background(Color(hex: "#f5f5f5"))
			.tipsToolbar(wifi: Monitors.shared.isConnected, notification: Monitors.shared.isAuthorized, callback: {
				manager.openSetting()
			})
			.toolbar {
				
				ToolbarItem {
					
					Button {
						showServerListView.toggle()
					} label: {
						Image(systemName: "externaldrive.badge.wifi")
							.foregroundStyle(serverTypeColor)
					}
					
				}
				
				
				
				
			}
			.sheet(isPresented: $isShareSheetPresented) {
				ShareSheet(fileUrl: jsonFileUrl!)
					.presentationDetents([.medium, .large])
			}
			.onAppear {
				manager.healths()
			}
			.navigationDestination(isPresented: $showServerListView) {
				ServersConfigView()
					.toolbar(.hidden, for: .tabBar)
			}
			
			
			
		}
		
	}
	
	private func maskString(_ str: String) -> String {
		guard str.count > 6 else {
			return str
		}
		
		let start = str.prefix(3)
		let end = str.suffix(4)
		let masked = String(repeating: "*", count: 5) // 固定为5个星号
		
		return start + masked + end
	}
	
	private func changeBadge(){
		
	}
	
	private func exportFile(){
//		self.showLoading = true
//		realm.exportFiles(messages){url, text in
//			if let url{
//				self.jsonFileUrl = url
//				self.isShareSheetPresented = true
//			}
//			self.showLoading = false
//		}
	}
	

	
}


#Preview {
	NavigationStack{
		SettingsView()
			.environment(PushupManager.shared)
	}
	
}
