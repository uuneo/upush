//
//  ImageCacheView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import Kingfisher
import Defaults

struct ImageCacheView: View {
	
	@Default(.photoName) var photoName
	@State var images:[URL] = []
	@State private var isSelect:Bool = false
	@State private var selectImageArr:[URL] = []
	@State private var showEditPhotoName:Bool = false
	@State private var alart:AlertData?
	
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
	
	var body: some View {
		
		VStack{
			
			ImageCacheHeaderView(photoCustomName: $photoName)
			
			
			ScrollView{
				
				LazyVGrid(columns: columns, spacing: 10) {
					ForEach(images, id: \.self){value in
						GridImageView(value: value,column: CGFloat(columns.count), selectImageArr: $selectImageArr, isSelect: $isSelect)
							.clipShape(RoundedRectangle(cornerRadius: 10))
						
					}
				}
				.padding(.horizontal, 10)
				
				
			}
		}.refreshable {
			getAllImages()
		}
		.onAppear{
			getAllImages()
		}
		.toolbar { toolbarContent() }
		.alert(item: $alart) { value in
			Alert(title: Text(value.title), message: Text(value.message), primaryButton: .cancel(), secondaryButton: .destructive(Text(value.btn), action: {
				switch value.mode{
				case .delte:
					self.deleteFile(at: self.selectImageArr)
					
				case .save:
					self.saveImage(self.selectImageArr, self.photoName)
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
						self.selectImageArr = self.images
					}
					
				} label: {
					Text( images.count == selectImageArr.count ? String(localized:  "取消全选") : String(localized: "全选"))
				}
			}
		}
		
		if isSelect{
			ToolbarItem(placement: .bottomBar) {
				HStack{
					
					ShareLink(items: selectImageArr.map({ value in
						Image(uiImage: UIImage(contentsOfFile: value.path())!)
					}), subject: Text(String(localized: "图片")), message: Text(String(localized: "图片"))) { value in
						SharePreview(String(localized:  "图片"), image: Image(uiImage:UIImage(contentsOfFile: images.first!.path())!))
					} label: {
						Image(systemName: "square.and.arrow.up")
					}.disabled(selectImageArr.count == 0)
					
					Spacer()
					Text( selectImageArr.count == 0 ? String(localized: "选择图片") : String(format: String(localized:  "已选择%d张图片"), selectImageArr.count))
					Spacer()
					Button {
						self.alart = .init(title: String(localized: "危险操作！"), message: String(format: String(localized: "删除%d张图片"), selectImageArr.count), btn: String(localized: "删除"), mode: .delte)
					} label: {
						Image(systemName: "trash")
					}.disabled(selectImageArr.count == 0)
					
					Button {
						self.alart = .init(title: String(localized:"保存图片"), message: String(format: String(localized: "保存%1$d张图片到 %2$@ 相册"), selectImageArr.count, photoName), btn: String(localized: "保存"), mode: .save)
					} label: {
						Image(systemName: "externaldrive.badge.plus")
					}.disabled(selectImageArr.count == 0)
				}
			}
			
		}
		
	}
	
	
	
	func saveImage(_ url:URL){
		guard  let image = UIImage(contentsOfFile: url.path()) else {
			debugPrint("ERROR:",url.absoluteString)
			return
		}
		image.bat_save(intoAlbum: self.photoName) { success, status in
			debugPrint(success,status)
		}
		
	}
	
	func saveImage(_ urls:[URL], _ photoName:String){
		
		for url in urls{
			
			if  let image = UIImage(contentsOfFile: url.path()){
				image.bat_save(intoAlbum: photoName) { success, status in
					debugPrint(success,status)
				}
			}else{
				debugPrint("ERROR:",url.absoluteString)
			}
			
		}
		
		
		
	}
	
	
	func getAllImages(){
		
		ImageManager.getCacheImage { results in
			self.images = results
		}
		
	}
	
	func deleteFile(at urls: [URL]) {
		//        FileManager.default?.removeItem(at: url)
		for url in urls{
			try? FileManager.default.removeItem(atPath: url.path())
			// Remove file from the list
			self.images.removeAll { $0 == url }
			
		}
		
	}
	
	
	
	
}

