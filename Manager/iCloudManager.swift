//
//  iCloudManager.swift
//  upush
//
//  Created by He Cho on 2024/10/19.
//

import Foundation


class iCloudManager{
	
	
	
	static func ceshi(){
		guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: BaseConfig.icloudName) else{
			return
		}
		
		debugPrint(containerURL)
		
		do{
			
			let fileURL = containerURL.appendingPathComponent("Documents").appendingPathComponent("hello.txt")
			try "hello world".write(to: fileURL, atomically: true, encoding: .utf8)
			
			if FileManager.default.fileExists(atPath: fileURL.path) {
				// 文件成功保存到iCloud
				debugPrint("保存成功",fileURL)
			} else {
				// 文件保存到iCloud失败
				debugPrint("保存失败",fileURL)
			}
			
			
		}catch{
			print(error.localizedDescription)
		}
		
		
		
		
	}
}
