//
//  RingtongView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import AVFoundation
import UIKit

struct RingtongView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(PushupManager.self) private var manager
	@State private var showUpload:Bool = false
	@StateObject private var audioManager = AudioManager.shared
	var body: some View {
		List {
			Section{
				ForEach(audioManager.customSounds, id: \.self) { url in
					RingtoneItemView(audio: url)
						.environmentObject(audioManager)
					
				}.onDelete { indexSet in
					for index in indexSet{
						audioManager.deleteSound(url: audioManager.customSounds[index])
					}
				}
			}header: {
				Text(String(localized:  "自定义铃声"))
			}
			
			
			
			Section {
				HStack{
					Spacer()
					Button {
						self.showUpload.toggle()
#if DEBUG
						print("上传铃声")
#endif
						
						
					} label: {
						Label(String(localized:  "上传铃声"), systemImage: "music.note" )
					}
					.fileImporter(isPresented: $showUpload, allowedContentTypes:  UTType.types(tag: "caf", tagClass: UTTagClass.filenameExtension,conformingTo: nil)) { result in
						switch result{
						case .success(let file):
							defer {
								file.stopAccessingSecurityScopedResource()
							}
#if DEBUG
							print(file)
#endif
							
							if file.startAccessingSecurityScopedResource() {
								audioManager.saveSound(url: file)
							}else{
#if DEBUG
								print("保存失败")
#endif
								
								
							}
							
						case .failure(let err):
#if DEBUG
							print(err)
#endif
							
						}
					}
					
					Spacer()
				}
			}footer: {
				HStack{
					Text(String(localized:  "请先将铃声"))
					Button{
						
						manager.webUrl = otherUrl.musicUrl
						manager.fullPage = .web
					}label: {
						Text(String(localized: "转换成 caf 格式"))
							.font(.footnote)
					}
					Text(String(localized: ",时长不超过 30 秒。"))
				}
			}
			
			
			Section{
				ForEach(audioManager.defaultSounds, id: \.self) { url in
					RingtoneItemView(audio: url)
						.environmentObject(audioManager)
				}
			}header: {
				Text(String(localized:  "自带铃声"))
			}
			
			
		}
	}
}

#Preview {
	RingtongView()
		.environment(PushupManager.shared)
}
