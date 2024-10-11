//
//  ServersConfiView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import Defaults

struct ServersConfigView: View {
	@Environment(\.dismiss) var dismiss
	@Default(.servers) var servers
	@Environment(PushupManager.self) private var manager

	@State private var showAction:Bool = false
	@State private var isEditing:EditMode = .inactive
	@State private var serverText:String = ""
	@State private var serverName:String = ""
	@State private var pickerSelect:requestHeader = .https

	var showClose:Bool = false
	
	var body: some View {
		NavigationStack{
			VStack{
				
				List{
					
					if isEditing == .active{
						Section {
							TextField(String(localized: "输入服务器地址"), text: $serverName)
								.textContentType(.flightNumber)
								.keyboardType(.URL)
								.autocapitalization(.none)
								.disableAutocorrection(true)
								.padding(.leading, 100)
								.overlay{
									HStack{
									
										Picker(selection: $pickerSelect) {
											Text(requestHeader.http.rawValue).tag(requestHeader.http)
											Text(requestHeader.https.rawValue).tag(requestHeader.https)
										}label:{}.pickerStyle(.automatic)
											.frame(maxWidth: 100)
											.offset(x:-30)
										Spacer()
									}
								}
							
						}header: {
							Text(String(localized: "新增服务器地址"))
						}footer: {
							HStack{
								Button{
									manager.webUrl = otherUrl.delpoydoc
									manager.fullPage = .web
								}label: {
									Text(String(localized: "查看服务器部署教程"))
										.font(.caption2)
								}
								
								Spacer()
								
								Button{
									
									_servers.reset()
									
								}label: {
									Text(String(localized: "恢复默认服务器"))
										.font(.caption2)
								}
							}.padding(.vertical)
						}
						
						
					}
					
					Spacer(minLength: 20)
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
					
					
					
					ForEach(servers, id: \.id){ item in
						HStack(alignment: .center){
							Image( item.status ? "online": "offline")
								.padding(.horizontal,5)
							VStack{
								HStack(alignment: .bottom){
									Text(String(localized: "服务器") + ":")
										.font(.system(size: 10))
										.frame(width: 40)
									Text(item.name)
										.font(.headline)
										.lineLimit(1)
										.minimumScaleFactor(0.5)
									Spacer()
								}
								
								HStack(alignment: .bottom){
									Text("KEY:")
										.frame(width:40)
									Text(item.key)
										.lineLimit(1)
										.minimumScaleFactor(0.5)
									Spacer()
								} .font(.system(size: 10))
								
							}
							Spacer()
							Image(systemName: "doc.on.doc")
								.onTapGesture{
									Toast.shared.present(title: String(localized: "复制成功"), symbol: .copy)
									manager.copy( item.url + "/" + item.key)
								}
							
						}
						.padding(.vertical,5)
						.swipeActions(edge: .leading, allowsFullSwipe: true) {
							
							Button {
								manager.fullPage = .login
								manager.sheetPage = .none
							} label: {
								Text(String(localized:  "修改key"))
							}.tint(.blue)
						}
						.listRowSeparator(.hidden)
						.swipeActions(edge: .leading) {
							Button{
								
								if let index = servers.firstIndex(where: {$0.id == item.id}){
									servers[index].key = ""
									manager.register(server: servers[index] ){ _, msg in
										Toast.shared.present(title: msg, symbol: "questionmark.bubble")
									}
								}else{
									Toast.shared.present(title: String(localized: "操作成功"), symbol: .success)
								}

								
							}label: {
								Text(String(localized: "重置Key"))
							}.tint(.red)
						}
						
					}
					.onDelete(perform: { indexSet in
						if isEditing == .active{
							if servers.count > 1{
								servers.remove(atOffsets: indexSet)
							}else{
								Toast.shared.present(title:String(localized: "必须保留一个服务"), symbol: .info)
							}
						}else{
							Toast.shared.present(title:String(localized: "编辑状态"), symbol: .info)
						}
					})
					.onMove(perform: { indices, newOffset in
						servers.move(fromOffsets: indices, toOffset: newOffset)
					})
					
					
				}
				.listRowSpacing(20)
				.refreshable {
					// MARK: - 刷新策略
					manager.registers()
				}
				
				
			}
			
			.toolbar{
				
				ToolbarItem {
					Button {
						manager.fullPage = .scan
					} label: {
						Image(systemName: "qrcode.viewfinder")
					}
					
				}
				
				ToolbarItem {
					EditButton()
				}
				
				
				if showClose {
					
					ToolbarItem{
						Button {
							dismiss()
						} label: {
							Image(systemName: "xmark.seal")
						}
						
					}
				}
			}
			.environment(\.editMode, $isEditing)
			.navigationTitle(String(localized: "服务器列表"))
			
			.onChange(of: isEditing) {
				if isEditing == .inactive && serverName.count > 0{
					let serverUrl = "\(pickerSelect.rawValue)\(serverName)"
					if serverUrl.isValidURL() == .remote {
						let item = PushServerModal(url: serverUrl)
						manager.appendServer(server: item){_,msg in
							Toast.shared.present(title: msg, symbol: .info)
							self.serverName = ""
						}
						
					}
					
					
				}
				
			}
			
		}
	}

}

#Preview {
	ServersConfigView()
		.environment(PushupManager.shared)
}
