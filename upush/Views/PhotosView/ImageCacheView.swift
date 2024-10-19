//
//  ImageCacheView.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import Defaults



struct ImageCacheView: View {
	
	@Environment(UpushManager.self) private var manager
	@Default(.photoName) var photoName
	@Default(.images) var images
	@State private var isSelect:Bool = false
	@State private var selectImageArr:[String] = []
	@State private var showEditPhotoName:Bool = false
	@State private var alart:AlertData?
	
	@FocusState private var nameFieldIsFocused
	
	@State private var draggImage:String?
	
	@State private var imageDetail:String?
	
	@State private var imagesData:[Image] = []
	
	@State private var dragSelectionRect = CGRect.zero
	
	enum AlertType{
		case delte
		case save
	}
	
	struct AlertData:Identifiable {
		var id: UUID = UUID()
		var title:String
		var message:String
		var btn:String
		var mode:AlertType
	}
	
	var columns:[GridItem]{
		if ISPAD{
			Array(repeating: GridItem(spacing: 2), count: 6)
		}else{
			Array(repeating: GridItem(spacing: 2), count: 3)
		}
	}
	
	var imageSize:CGSize{
		let width = Int(UIScreen.main.bounds.width) / columns.count - 10;
		return CGSize(width: width, height: width)
	}
	
	
	var body: some View {
		
		ZStack{
			ScrollView{
//				ImageCacheHeaderView()
				
				LazyVGrid(columns: columns, spacing: 10) {
					PhotoPickerView(draggImage: $draggImage, imageSize: imageSize)
					
					ForEach( images, id: \.self){ item  in
						uAsyncImage(url: item,size: imageSize) { draggImage = $0}
							.frame(width: imageSize.width,height: imageSize.height)
							.overlay(alignment: .bottomTrailing) {
								if selectImageArr.contains(item){
									Image(systemName: "checkmark.circle")
										.symbolRenderingMode(.palette)
										.foregroundStyle( .green, Color.primary)
										.blendMode(.hardLight)
										.font(.largeTitle)
//										.symbolEffect(.pulse)
										.frame(width: 35, height: 35, alignment: .center)
										.background(.ultraThinMaterial)
										.clipShape(Circle())
										.padding(.trailing, 10)
										.padding(.bottom, 10)
								}
							}
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.contentShape((RoundedRectangle(cornerRadius: 10)))
							.onTapGesture {
								if isSelect{
									if selectImageArr.contains(where: {$0 == item}){
										selectImageArr.removeAll(where: {$0 == item})
									}else{
										self.selectImageArr.append(item)
									}
									
								}else{
									self.imageDetail = item
								}
							}
							.animation(.snappy, value: images)
						
						
					}
				}
				.padding(.horizontal, 10)
				
			}
			.safeAreaPadding(.bottom, 50)
			
			if let imageDetail {
				ImageDetailView(image: imageDetail,imageUrl: $imageDetail )
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: .center)
					.contentTransition(.identity)
			}
		}
		
			.toolbar { toolbarContent() }
			.alert(item: $alart) { value in
				Alert(title: Text(value.title), message: Text(value.message), primaryButton: .cancel(), secondaryButton: .destructive(Text(value.btn), action: {
					switch value.mode{
					case .delte:
						Task.detached {
							
							if await selectImageArr.count == 0{
								await ImageManager.deleteFilesNotInList(all: true)
							}else{
								for item in await selectImageArr{
									_ = await ImageManager.deleteImage(for: item)
								}
							}
							await MainActor.run {
								self.selectImageArr = []
							}
							Toast.shared.present(title: value.message, symbol: "photo.badge.checkmark")
						}
					case .save:
						self.saveImage(self.selectImageArr)
					}
					self.isSelect.toggle()
				}))
			}
			
		}
	
	
	
	@ToolbarContentBuilder
	private func toolbarContent() -> some ToolbarContent{
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				self.isSelect.toggle()
				self.selectImageArr = []
			} label: {
				Text( isSelect  ? String(localized: "取消") : String(localized: "选择"))
			}.disabled(images.count == 0)
		}
		
		if isSelect && images.count > 2{
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					if images.count == selectImageArr.count{
						self.selectImageArr = []
					}else{
						self.selectImageArr = images
					}
					
				} label: {
					Text( images.count == selectImageArr.count ? String(localized:  "取消全选") : String(localized: "全选"))
				}
			}
		}
		
		if isSelect {
			ToolbarItem(placement: .bottomBar) {
				HStack{
					
					ShareLink(items: imagesData, subject: Text(String(localized: "图片")), message: Text(String(localized: "图片"))) { value in
						SharePreview( String(format: String(localized:  "%d张图片"), imagesData.count) , image: value)
					} label: {
						Image(systemName: imagesData.count > 0 ? "square.and.arrow.up" : "square.and.arrow.up.badge.clock")
//							.contentTransition(.symbolEffect(.replace))
					}.disabled(selectImageArr.count == 0 || images.count == 0)
						
					
					
					Spacer()
					Text( selectImageArr.count == 0 ? String(localized: "选择图片") : String(format: String(localized:  "已选择%d张图片"), selectImageArr.count))
						.animation(.snappy, value: selectImageArr.count)
					Spacer()
					Button {
						self.alart = .init(title: String(localized: "危险操作！"), message: selectImageArr.count == 0 ? String(localized: "清空所有") : String(format: String(localized: "删除%d张图片"), selectImageArr.count), btn: String(localized: "删除"), mode: .delte)
					} label: {
						Image(systemName: imagesData.count > 0 ? "trash" : "trash.slash")
//							.contentTransition(.symbolEffect(.replace))
					}
						
					
					Button {
						self.alart = .init(title: String(localized:"保存图片"), message: String(format: String(localized: "保存%1$d张图片到 %2$@ 相册"), selectImageArr.count, photoName), btn: String(localized: "保存"), mode: .save)
					} label: {
						Image(systemName:  imagesData.count > 0 ? "externaldrive.badge.plus" : "externaldrive.badge.questionmark")
//							.contentTransition(.symbolEffect(.replace))
					}.disabled(selectImageArr.count == 0 || images.count == 0)
				}
				
				.onChange(of: selectImageArr) { _, newValue in
					loadSharkImages(images: newValue)
				}
				
			}
			
		}
			
		
	}
	
	
	@ViewBuilder
	private func ImageCacheHeaderView() -> some View{
		HStack{
			Label(String(localized:  "相册名"), systemImage: "photo.badge.plus")
//				.symbolEffect(.pulse)
				.symbolRenderingMode(.palette)
				.foregroundStyle( .tint, Color.primary)
			
			Spacer()
			TextField(
				String(localized:  "相册名"),
				text: $photoName
			)
			.foregroundStyle(Color.primary)
			.multilineTextAlignment(.trailing)
			.padding(.trailing, 30)
			.overlay {
				HStack{
					Spacer()
					Button {
						self.nameFieldIsFocused.toggle()
					} label: {
						Image(systemName: "square.and.pencil.circle")
							.symbolEffect(.pulse)
							.symbolRenderingMode(.palette)
							.foregroundStyle( .tint, Color.primary)
					}
					
				}
			}
			.focused($nameFieldIsFocused)
			.onChange(of: photoName) {_, newValue in
				// 去除空格并更新绑定的文本值
				photoName = newValue.trimmingCharacters(in: .whitespaces)
			}
			.toolbar {
				if nameFieldIsFocused{
					ToolbarItemGroup(placement: .keyboard) {
						
						Button(String(localized: "清除")) {
							self.photoName = ""
						}
						
						Spacer()
						Button(String(localized: "完成")) {
							nameFieldIsFocused = false
						}
						
					}
				}
				
			}
			
			
			
		}.padding()
			.padding(.horizontal)
	}
	
	
	
	func saveImage(_ items:[String]){
		
		Task.detached(priority: .background) {
			for item in items{
				if let fileUrl = await ImageManager.fetchImage(from: item),
				   let image = UIImage(contentsOfFile: fileUrl)
				{
					await image.bat_save(intoAlbum: self.photoName) { success, status in
						debugPrint(success,status)
					}
				}else{
					debugPrint("save errorr")
				}
				
				
			}
			
			await MainActor.run {
				self.selectImageArr = []
			}
		}
		
		
	}
	
	
	func loadSharkImages(images: [String]){
		var results:[Image] = []
		Task.detached(priority: .background) {
			
			for item in images{
				if let fileUrl = await ImageManager.fetchImage(from: item),
				   let uiimage = UIImage(contentsOfFile: fileUrl)
				{
					results.append(Image(uiImage: uiimage))
					
				}
			}
			await MainActor.run {
				self.imagesData = results
			}
		}
	}
	
	
	
	
	
	
}





#Preview {
	ImageCacheView()
		.environment(UpushManager.shared)
}
