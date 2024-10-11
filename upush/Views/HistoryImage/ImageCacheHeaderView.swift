//
//  ImageCacheHeaderView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI

struct ImageCacheHeaderView: View{
	@Binding var photoCustomName:String
	@FocusState private var nameFieldIsFocused
	var body: some View{
		HStack{
			Label(String(localized:  "相册名"), systemImage: "photo.badge.plus")
			Spacer()
			TextField(
				String(localized:  "相册名"),
				text: $photoCustomName
			)
			.foregroundStyle(Color.appProfileBlue)
			.multilineTextAlignment(.trailing)
			.padding(.trailing, 30)
			.overlay {
				HStack{
					Spacer()
					Button {
						self.nameFieldIsFocused.toggle()
					} label: {
						Image(systemName: "pencil.line")
					}
					
				}
			}
			.focused($nameFieldIsFocused)
			.onChange(of: photoCustomName) {_, newValue in
				// 去除空格并更新绑定的文本值
				photoCustomName = newValue.trimmingCharacters(in: .whitespaces)
			}
			.toolbar {
				ToolbarItemGroup(placement: .keyboard) {
					
					Button(String(localized: "清除")) {
						self.photoCustomName = ""
					}
					
					Spacer()
					Button(String(localized: "完成")) {
						nameFieldIsFocused = false
					}
					
				}
			}
			
			
			
		}.padding()
			.padding(.horizontal)
	}
	
}

