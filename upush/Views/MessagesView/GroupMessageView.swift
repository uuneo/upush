//
//  GroupMessageView.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import RealmSwift
import Defaults

struct GroupMessageView: View {
	
	@ObservedSectionedResults(Message.self,sectionKeyPath: \.group,sortDescriptors: [ SortDescriptor(keyPath: "createDate", ascending: false)]) var messages
	
	@Environment(UpushManager.self) private var manager
	@Default(.appIcon) private var appicon
	@State private var showAction = false
	@State private var helpviewSize:CGSize = .zero
	@State private var searchText:String = ""
	@State private var showExample:Bool = false

	
	var body: some View {
		NavigationStack{
			List {
				
				
				ForEach(messages,id: \.key){ groupMessage in
					
					NavigationLink {
						
						MessagesView(group: groupMessage.key)
							.toolbar(.hidden, for: .tabBar)
							.navigationTitle(groupMessage.key)
					} label: {
						MessageRow(message: groupMessage.first!, unreadCount: unRead(groupMessage))
							.swipeActions(edge: .leading) {
								Button {
									
									Task{
										
										RealmProxy.shared.read(groupMessage.key)
									}
									
								} label: {
									
									Label( String(localized: "标记"), systemImage: unRead(groupMessage) == 0 ?  "envelope.open" : "envelope")
										.symbolRenderingMode(.palette)
										.foregroundStyle(.white, Color.primary)
//										.contentTransition(.symbolEffect(.replace.downUp.byLayer, options: .repeat(.continuous)))
									
								}.tint(.blue)
							}
						
					}
					
					
					
				}.onDelete(perform: { indexSet in
					for index in indexSet{
						RealmProxy.shared.delete( messages[index].key)
					}
				})
			}
			.listStyle(.plain)
			.navigationTitle(String(localized: "信息"))
			
			.navigationDestination(isPresented: $showExample){
				ExampleView()
			}
			
			.tipsToolbar(wifi: Monitors.shared.isConnected, notification: Monitors.shared.isAuthorized, callback: {
				manager.openSetting()
			})
			.toolbar{
				
				ToolbarItem{
					
					Button{
						self.showExample.toggle()
					}label:{
						Image(systemName: "questionmark.circle.dashed")
							.symbolRenderingMode(.palette)
							.foregroundStyle(.green, Color.primary)
//							.symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
					}
					
				}
				
				
				ToolbarItem {
					
					
					
					if ISPAD{
						Menu {
							
							ForEach( MessageAction.allCases, id: \.self){ item in
								Button{
									deleteMessage(item)
								}label:{
									Label(item.localized, systemImage: (item == .cancel ? "arrow.uturn.right.circle" : item == .markRead ? "text.badge.checkmark" : "xmark.bin.circle"))
										.symbolRenderingMode(.palette)
										.foregroundStyle(.green, Color.primary)
//										.symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 3.0)))
								}
							}
						} label: {
							Image(systemName: "trash.circle")
								.symbolRenderingMode(.palette)
								.foregroundStyle(.green, Color.primary)
//								.symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 5.0)))
						}
						
						
					}else{
						
						Button{
							self.showAction = true
						}label: {
							Image(systemName: "trash.circle")
								.symbolRenderingMode(.palette)
								.foregroundStyle(.green, Color.primary)
//								.symbolEffect(.bounce.up.byLayer, options: .repeat(.periodic(delay: 5.0)))
							
						}
						
						
					}
					
				}
				
				
			}
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)){
				SearchMessageView(searchText: searchText, group: searchText)
			}
			.actionSheet(isPresented: $showAction) {
				
				ActionSheet(title: Text(String(localized: "删除以下时间的信息!")),
							buttons: MessageAction.allCases.map({ item in
					
					switch item{
					case .cancel:
						Alert.Button.cancel()
					case .markRead:
						Alert.Button.default(Text(item.localized), action: {
							deleteMessage(item)
						})
					default:
						Alert.Button.destructive(Text(item.localized), action: {
							deleteMessage(item)
						})
					}
					
				}))
			}
		}
	}
	
	
	
	func deleteMessage(_ mode: MessageAction){
		
		
		if messages.count == 0{
			Toast.shared.present(title: "没有消息", symbol: .error)
			return
		}
		
		switch mode {
		case .markRead:
			RealmProxy.shared.read()
		case .cancel:
			break
		default:
			RealmProxy.shared.delete(mode.date)
		}
		
		Toast.shared.present(title: "删除成功", symbol: .success)
		
		
		
	}
	
	@ViewBuilder
	func MessageRow(message: Message,unreadCount: Int )-> some View{
		HStack {
			if unreadCount > 0 {
				Circle()
					.fill(Color.blue)
					.frame(width: 10, height: 10)
			}
			
			AvatarView(id: message.id, icon: message.icon, mode: message.mode)
				.frame(width: 45, height: 45)
				.clipped()
				.clipShape(RoundedRectangle(cornerRadius: 10))
			
			VStack(alignment: .leading) {
				HStack {
					Text(message.group)
						.font(.headline.weight(.bold))
						.foregroundStyle(.textBlack)
					
					Spacer()
					
					Text(message.createDate.agoFormatString())
						.font(.caption2)
				}
				
				HStack {
					if let title = message.title {
						Text("【\(title)】\(message.body ?? "")")
					} else {
						Text(message.body ?? "")
					}
				}
				.font(.footnote)
				.lineLimit(2)
				.foregroundStyle(.gray)
			}
		}
	}
	
	
	private func unRead(_ messages: ResultsSection<String,Message>) -> Int{
		messages.filter {!$0.read}.count
	}
	
	
}


#Preview {
	GroupMessageView()
		.environment(UpushManager.shared)
}
