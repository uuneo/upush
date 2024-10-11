//
//  MessagesView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import RealmSwift
import Defaults

struct MessagesView: View {
	
	@Environment(PushupManager.self) private var manager
	@ObservedSectionedResults(Message.self,sectionKeyPath: \.group,sortDescriptors: [ SortDescriptor(keyPath: "createDate", ascending: false)]) var messages

	@Default(.appIcon) var setting_active_app_icon
	@State private var showAction = false
	@State private var helpviewSize:CGSize = .zero
	@State private var searchText:String = ""
	@State private var showExample:Bool = false
	@State private var selectMessages:ResultsSection<String, Message>?
	var body: some View {
		NavigationStack{
			List {
				
				ForEach(messages,id: \.key){ message2 in
					
					VStack{
						Button{
							self.selectMessages = message2
						}label: {
							MessageRow(message: message2.first!, unreadCount: unReadCount(message2))
						}
					}
					
					.swipeActions(edge: .leading) {
						Button {
							RealmProxy.shared.readAll(group: message2.key)
						} label: {
							Label(String(localized:  "组已读"),
								  systemImage: unReadCount(message2) == 0 ?  "envelope.open" : "envelope")
						}.tint(.blue)
					}
					
				}
				.onDelete { indexSet in
					for index in indexSet{
						RealmProxy.shared.deleteByGroup(group: messages[index].key)
					}
				}
				
			}
			.listStyle(.plain)
			.navigationDestination(isPresented: $showExample){
				ExampleView()
			}
			.navigationDestination(item: $selectMessages, destination: { item in
				MessageDetailView(messages: item)
					.toolbar(.hidden, for: .tabBar)
					.navigationTitle(item.key)
			})
			.tipsToolbar(wifi: Monitors.shared.isConnected, notification: Monitors.shared.isAuthorized, callback: {
				manager.openSetting()
			})
			.toolbar{
				
				
				ToolbarItem {
					
					Button{
						self.showExample.toggle()
					}label:{
						Image(systemName: "questionmark.circle")
						
					} .foregroundStyle(.foreground)
						.accessibilityIdentifier("HelpButton")
				}
				
				
				ToolbarItem{
					
					if ISPAD{
						Menu {
							
							ForEach(MessageAction.allCases, id: \.self){ item in
								Button{
									deleteMessage(item)
								}label:{
									Label( item.localized , systemImage: (item == .cancel ? "arrow.uturn.right.circle" : item == .markRead ? "text.badge.checkmark" : "xmark.bin.circle"))
								}
							}
						} label: {
							Image("baseline_delete_outline_black_24pt")
								.foregroundStyle(.foreground)
						}
							
							
					}else{
						
						Button{
							self.showAction = true
						}label: {
							Image("baseline_delete_outline_black_24pt")
							
						}  .foregroundStyle(.foreground)
						
						
					}
						
				}
			}
			.searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)){
				SearchMessageView(searchText: $searchText)
			}
			.actionSheet(isPresented: $showAction) {
				
				ActionSheet(title: Text( String(localized: "删除以下时间的消息") ),
							buttons: MessageAction.allCases.map({ item in
					if item == .cancel{
						Alert.Button.cancel()
					} else if item  == .markRead{
						Alert.Button.default(Text( item.localized ), action: {
							deleteMessage(item)
						})
					}else{
						Alert.Button.destructive( Text( item.localized ), action: {
							deleteMessage(item)
						})
					}
					
				}))
			}
		}
		.onReceive(NotificationCenter.default.publisher(for: .messagePreview)) { _ in
			manager.page = .message
			manager.fullPage = .none
			manager.sheetPage = .none
			self.showExample = false
			self.selectMessages = nil
		}
		
		
	}
	
	
	
	func deleteMessage(_ mode: MessageAction){

		if messages.count == 0{
			Toast.shared.present(title: String(localized: "没有消息"), symbol: "questionmark.circle.dashed")
			return
		}
		
		switch mode {
		case .markRead:
			RealmProxy.shared.readAll()
			Toast.shared.present(title: String(localized: "全部已读"), symbol: "checkmark.arrow.trianglehead.counterclockwise")
		case .cancel:
			break
		default:
			RealmProxy.shared.deleteByDate(date: mode.date)
		}
		Toast.shared.present(title: String(localized: "删除成功"), symbol: "checkmark.arrow.trianglehead.counterclockwise")
		
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
						.foregroundStyle(.foreground)
					
					Spacer()
					
					Text(message.createDate.agoFormatString())
						.foregroundStyle(message.createDate.colorForDate())
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
			.navigationTitle(String(localized: "消息"))
		}
		
	}
	
	
	private func unReadCount(_ messages: ResultsSection<String, Message>) -> Int{
		return messages.filter({ !$0.read }).count
	}
	
}



#Preview {
	NavigationStack{
		MessagesView()
			.environment(PushupManager.shared)
	}
	
}
