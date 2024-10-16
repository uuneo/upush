//
//  GridImageView.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import SwiftUI
import Kingfisher


struct GridImageView: View {
	var value:URL
	var column:CGFloat
	@Binding var selectImageArr:[URL]
	@Binding var isSelect:Bool
	
	var imageSize:CGSize{
		
		let width = UIScreen.main.bounds.width / column - 10;
		
		return CGSize(width: width, height: width)
	  
	   
	}
	
	var body: some View {
		KFImage(value)
			.resizable()
			.aspectRatio(contentMode: .fill)
			.draggable(Image(uiImage: UIImage(contentsOfFile: value.path())!))
			.frame(width: imageSize.width,height: imageSize.height)
			.clipped()
			.overlay {
				if isSelect && selectImageArr.contains(value){
					ZStack{
						RoundedRectangle(cornerRadius: 0)
							.foregroundStyle(Color.clear)
							.background(.ultraThinMaterial.opacity(0.6))
						VStack{
							Spacer()
							HStack {
								Spacer()
								Image(systemName: "checkmark.circle")
									.foregroundStyle(Color.green)
									.padding()
								
							}
						}
					}
					
				}else{
					EmptyView()
				}
				
			}
			
			.onTapGesture {
				if isSelect{
					if selectImageArr.contains(value){
						self.selectImageArr.removeAll { $0 == value }
					}else{
						self.selectImageArr.append(value)
					}
				}
			}.onLongPressGesture {
				if !isSelect{
					self.isSelect.toggle()
					self.selectImageArr.append(value)
				}
			}
		   
	}
}
