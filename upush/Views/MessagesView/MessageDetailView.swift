//
//  MessageDetailView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import RealmSwift

struct MessageDetailView: View {
	var messages:ResultsSection<String, Message>
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.presentationMode) var presentationMode
	
	var body: some View {
		
		List {
				ForEach(messages, id: \.id) { message in
					
					MessageView(message: message)
						.swipeActions(edge: .leading) {
							Button {
								RealmProxy.shared.isRead(message: message)
								Toast.shared.present(title: String(localized:  "信息状态已更改"), symbol: "highlighter")
							} label: {
								Label(message.read ? String(localized: "已读") :  String(localized: "未读"), systemImage: message.read ? "envelope.open": "envelope")
							}.tint(.blue)
						}
					
						.listRowBackground(Color.clear)
						.listSectionSeparator(.hidden)
					
					
				}
				.onDelete { indexSet in
					for index in indexSet{
						RealmProxy.shared.delete(message: messages[index])
					}
				}
			
			
			
		}
		.toolbar{
			ToolbarItem {
				Text("\(messages.count)")
					.font(.caption)
			}
		}
		
		.onChange(of: messages) { _, value in
			if value.count <= 0 {
				dismiss()
			}
		}.onAppear{
			RealmProxy.shared.readAll(group: messages.first!.group)
		}
		
	}
}
