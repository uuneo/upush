//
//  upushApp.swift
//  upush
//
//  Created by He Cho on 2024/10/11.
//

import SwiftUI

@main
struct PushupApp: SwiftUI.App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	var manager = PushupManager.shared
	var body: some Scene {
		WindowGroup {
			RootView{
				ContentView()
			}
			.environment(manager)
				
		}
	}
}
