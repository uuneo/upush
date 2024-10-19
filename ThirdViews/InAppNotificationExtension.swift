//
//  InAppNotificationExtension.swift
//  upush
//
//  Created by He Cho on 2024/10/12.
//

import SwiftUI

/// Root View for Creating Overlay Window
struct DynamicToastView<Content: View>: View {
	@ViewBuilder var content: Content
	/// View Properties
	@State private var overlayWindow: UIWindow?
	var body: some View {
		content
			.onAppear(perform: {
				if overlayWindow == nil {
					if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
						let overlayWindow = PassThroughWindow(windowScene: windowScene)
						overlayWindow.backgroundColor = .clear
						overlayWindow.tag = 0320
						let controller = StatusBarBasedController()
						controller.view.backgroundColor = .clear
						overlayWindow.rootViewController = controller
						overlayWindow.isHidden = false
						overlayWindow.isUserInteractionEnabled = true
						self.overlayWindow = overlayWindow
						//print("Overlay Window Created")
					}
				}
			})
	}
}


class StatusBarBasedController: UIViewController {
	var statusBarStyle: UIStatusBarStyle = .default
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}
}

fileprivate class PassThroughWindow: UIWindow {
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		guard let view = super.hitTest(point, with: event) else { return nil }
		return rootViewController?.view == view ? nil : view
	}
}



extension UIApplication {
	func inAppNotification<Content: View>(adaptForDynamicIsland: Bool = false, timeout: CGFloat = 5, swipeToClose: Bool = true, @ViewBuilder content: @escaping (Bool) -> Content) {
		/// Fetching Active Window VIA WindowScene
		if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
			/// Frame and SafeArea Values
			let frame = activeWindow.frame
			let safeArea = activeWindow.safeAreaInsets
			
			var tag: Int = 1009
			let checkForDynamicIsland = adaptForDynamicIsland && safeArea.top >= 51
			
			if let previousTag = UserDefaults.standard.value(forKey: "in_app_notification_tag") as? Int {
				tag = previousTag + 1
			}
			
			UserDefaults.standard.setValue(tag, forKey: "in_app_notification_tag")
			
			/// Changing Status into Black to blend with Dynamic Island
			if checkForDynamicIsland {
				if let controller = activeWindow.rootViewController as? StatusBarBasedController {
					controller.statusBarStyle = .darkContent
					controller.setNeedsStatusBarAppearanceUpdate()
				}
			}
			
			/// Creating UIView from SwiftUIView using UIHosting Configuration
			let config = UIHostingConfiguration {
				AnimatedNotificationView(
					content: content(checkForDynamicIsland),
					safeArea: safeArea,
					tag: tag,
					adaptForDynamicIsland: checkForDynamicIsland,
					timeout: timeout,
					swipeToClose: swipeToClose
				)
				/// Maximum Notification Height will be 120
				.frame(width: frame.width - (checkForDynamicIsland ? 20 : 30), height: 120, alignment: .top)
				.contentShape(.rect)
			}
			
			/// Creating UIView
			let view = config.makeContentView()
			view.tag = tag
			view.backgroundColor = .clear
			view.translatesAutoresizingMaskIntoConstraints = false
			
			if let rootView = activeWindow.rootViewController?.view {
				/// Adding View to the Window
				rootView.addSubview(view)
				
				/// Layout Constraints
				view.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
				view.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: (-(frame.height - safeArea.top) / 2) + (checkForDynamicIsland ? 11 : safeArea.top)).isActive = true
			}
		}
	}
}

fileprivate struct AnimatedNotificationView<Content: View>: View {
	var content: Content
	var safeArea: UIEdgeInsets
	var tag: Int
	var adaptForDynamicIsland: Bool
	var timeout: CGFloat
	var swipeToClose: Bool
	/// View Properties
	@State private var animateNotification: Bool = false
	@State private var viewSize: CGSize = .zero
	var body: some View {
		content
			.opacity(adaptForDynamicIsland ? (animateNotification ? 1 : 0) : 1)
			.blur(radius: animateNotification ? 0 : 10)
			.disabled(!animateNotification)
			.size {
				viewSize = $0
			}
			.background(content: {
				if adaptForDynamicIsland {
					Rectangle()
						.fill(.black)
				}
			})
			.mask {
				if adaptForDynamicIsland {
					/// Size Based Capusule
					GeometryReader(content: { geometry in
						let size = geometry.size
						let radius = size.height / 2
						
						RoundedRectangle(cornerRadius: radius, style: .continuous)
					})
				} else {
					Rectangle()
				}
			}
			/// Scaling Animation only For Dynamic Island Notification
			/// Approx Dynamic Island Size = (126, 37.33)
			.scaleEffect(
				x: adaptForDynamicIsland ? (animateNotification ? 1 : (120 / viewSize.width)) : 1,
				y: adaptForDynamicIsland ? (animateNotification ? 1 : (35 / viewSize.height)) : 1,
				anchor: .top
			)
			/// Offset Animation for Non Dynamic Island Notification
			.offset(y: offsetY)
			.gesture(
				DragGesture()
					.onEnded({ value in
						if -value.translation.height > 30 && swipeToClose {
							withAnimation(.smooth, completionCriteria: .logicallyComplete) {
								animateNotification = false
							} completion: {
								removeNotificationViewFromWindow()
							}
						}
					})
			)
			.onAppear(perform: {
				Task {
					guard !animateNotification else { return }
					withAnimation(.smooth) {
						animateNotification = true
					}
					
					/// Timeout For Notification
					try await Task.sleep(for: .seconds(timeout < 1 ? 1 : timeout))
					
					guard animateNotification else { return }
					
					withAnimation(.smooth, completionCriteria: .logicallyComplete) {
						animateNotification = false
					} completion: {
						removeNotificationViewFromWindow()
					}
				}
			})
	}
	
	var offsetY: CGFloat {
		if adaptForDynamicIsland {
			return animateNotification ? 0 : 1.33
		}
		
		return animateNotification ? 10 : -(safeArea.top + 130)
	}
	
	func removeNotificationViewFromWindow() {
		if let activeWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }) {
			if let view = activeWindow.viewWithTag(tag) {
				//print("Removed View with \(tag)")
				view.removeFromSuperview()
				
				/// Resetting Once All the notifications was removed
				if let controller = activeWindow.rootViewController as? StatusBarBasedController, controller.view.subviews.isEmpty {
					controller.statusBarStyle = .default
					controller.setNeedsStatusBarAppearanceUpdate()
				}
			}
		}
	}
}

struct SizeKey: PreferenceKey {
	static var defaultValue: CGSize = .zero
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

fileprivate extension View {
	@ViewBuilder
	func size(value: @escaping (CGSize) -> ()) -> some View {
		self
			.overlay {
				GeometryReader(content: { geometry in
					let size = geometry.size
					
					Color.clear
						.preference(key: SizeKey.self, value: size)
						.onPreferenceChange(SizeKey.self, perform: {
							value($0)
						})
				})
			}
	}
}

