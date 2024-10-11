//
//  BsyncView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//


import SwiftUI
import Photos
import Defaults


struct BsyncImageView:View {
	var url:String
	var mode: ContentMode = .fit
	@State private var image: UIImage?
	
	var body: some View {
		GeometryReader {
			let size = $0.size
			
			VStack{
				if let image = image {
					// 如果已经加载了图片，则显示图片
					Image(uiImage: image)
						.resizable()
						.frame(width: size.width, height: size.height)
					
				} else {
					// 如果图片尚未加载，则显示加载中的视图
					ProgressView()
						.frame(width: size.width / 2, height: size.height / 2)
						.task {
							await loadImage(url: url )
						}
					
				}
			}.aspectRatio(contentMode: mode)
			
			
		}
	}
	
	
	private func loadImage(url:String ) async {
		let urlType = url.isValidURL()
		
		switch urlType {
		case .remote:
			if let imagePath = await ImageManager.downloadImage(url) {
				await MainActor.run {
					self.image = UIImage(contentsOfFile: imagePath)
				}
			}
		case .local:
			self.image = UIImage(contentsOfFile: url)
		case .none:
			self.image = UIImage(named: url)
		}
		
		
	}
}



struct AvatarView: View {
	
	var id:String?
	var icon:String?
	var mode:String?
	
	@Default(.appIcon) var appicon
	
	@State private var success:Bool = true
	@State private var image: UIImage?
	
	
	var body: some View {
		GeometryReader {
			let size = $0.size
			
			VStack{
				if let icon = icon, icon.isValidURL() == .remote, success{
					if let image = image {
						// 如果已经加载了图片，则显示图片
						Image(uiImage: image)
							.resizable()
							.frame(width: size.width, height: size.height)
						
					} else {
						// 如果图片尚未加载，则显示加载中的视图
						ProgressView()
							.frame(width: size.width, height: size.height)
							.task {
								await loadImage(icon: icon)
							}
						
					}
				}else{
					if mode == "1"{
						Image(AppIconEnum.def.logo)
							.resizable()
							.frame(width: size.width, height: size.height)
					}else{
						Image(appicon.logo)
							.resizable()
							.frame(width: size.width, height: size.height)
					}
				}
				
			}
			.aspectRatio(contentMode: .fill )
			
		}
		
		
	}
	
	private func loadImage(icon:String ) async {
		if let imagePath = await ImageManager.downloadImage(icon) {
			await MainActor.run {
				self.image = UIImage(contentsOfFile: imagePath)
			}
		} else {
			await MainActor.run {
				self.success = false
			}
		}
	}
}
