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
			let fileURL = containerURL.appendingPathComponent("upush").appendingPathComponent("hello.txt")
			try "hello world".write(to: fileURL, atomically: true, encoding: .utf8)
		}catch{
			print(error.localizedDescription)
		}
		
		
		
		
	}
}
