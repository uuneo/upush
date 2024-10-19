//
//  upushApp.swift
//  upush
//
//  Created by He Cho on 2024/10/11.
//

import SwiftUI
import SwiftData

@main
struct upushApp: SwiftUI.App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	var manager = UpushManager.shared
	var body: some Scene {
		WindowGroup {
			RootView{
				ContentView()
					
			}
			.environment(manager)
		}
	}
}
