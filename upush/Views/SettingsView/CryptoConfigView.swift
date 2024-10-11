//
//  CryptoConfigView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import Defaults

struct CryptoConfigView: View {
	@Environment(\.dismiss) var dismiss
	@Environment(PushupManager.self) private var manager
	@Default(.cryptoConfig) var cryptoConfig
	@Default(.servers) var servers
	var expectKeyLength:Int {
		cryptoConfig.algorithm.rawValue
	}
	
	
	var body: some View {
		List {
			
			
			Section{
				Picker(selection: $cryptoConfig.algorithm, label: Text(String(localized: "算法"))) {
					ForEach(CryptoAlgorithm.allCases,id: \.self){item in
						Text(item.name).tag(item)
					}
				}
			}
			
			Section {
				Picker(selection: $cryptoConfig.mode, label: Text(String(localized:  "模式"))) {
					ForEach(CryptoMode.allCases,id: \.self){item in
						Text(item.rawValue).tag(item)
					}
				}
			}
			
			Section {
				
				HStack{
					Label {
						Text("Padding:")
					} icon: {
						Image(systemName: "space")
					}
					Spacer()
					Text(cryptoConfig.mode.padding)
						.foregroundStyle(.gray)
				}
				
			}
			
			Section {
				
				HStack{
					Label {
						Text("Key：")
					} icon: {
						Image(systemName: "key")
					}
					Spacer()
					
					TextEditor(text: $cryptoConfig.key)
						
						.overlay{
							if cryptoConfig.key.isEmpty{
								Text(String(format: String(localized: "输入%d位数的key"), expectKeyLength))
									
							}
						}
						.onDisappear{
							let _ = verifyKey()
						}
						.foregroundStyle(.gray)
						.lineLimit(2)
				
					
				}
				
				
				
			}
			
			
			Section {
				
				
				HStack{
					Label {
						Text("Iv：")
					} icon: {
						Image(systemName: "dice")
					}
					Spacer()
					
					TextEditor(text: $cryptoConfig.iv)
						
						.overlay{
							if cryptoConfig.iv.isEmpty{
								Text(String(localized: "请输入16位Iv"))
									
							}
						}
						.onDisappear{
							let _ = verifyIv()
						}
						.foregroundStyle(.gray)
						.lineLimit(2)
					
						
				}
				
				
			}
			
			
			
			HStack{
				Spacer()
				Button {
					createCopyText()
				} label: {
					Text(String(localized:  "复制发送脚本"))
						.padding(.horizontal)
					
				}.buttonStyle(BorderedProminentButtonStyle())
				
				
				
				Spacer()
			} .listRowBackground(Color.clear)
			
			
			
			
			
			
		}.navigationTitle(String(localized:  "算法配置"))
			.toolbar{
				ToolbarItem {
					Button {
						if verifyKey() && verifyIv(){
							
							Toast.shared.present(title: String(localized:  "验证成功"), symbol: .success)
							
							
						}
					} label: {
						Text(String(localized:  "验证"))
					}
					
				}
			}
		
	}
	func verifyKey()-> Bool{
		if cryptoConfig.key.count != expectKeyLength{
			cryptoConfig.key = ""
		
			Toast.shared.present(title: String(localized:  "Key参数长度不正确"), symbol: .info)
			return false
		}
		return true
	}
	
	func verifyIv() -> Bool{
		if cryptoConfig.iv.count != 16 {
			cryptoConfig.iv = ""
			Toast.shared.present(title: String(localized:  "Iv参数长度不正确"), symbol: .info)
			return false
		}
		return true
	}
	
	
	func createCopyText(){
		
		
		if !verifyIv() {
			cryptoConfig.iv = CryptoModal.generateRandomString(by32: false)
		}
		
		if !verifyKey(){
			cryptoConfig.key = CryptoModal.generateRandomString(by32: expectKeyLength == 32)
		}
		
		
		
		let text = """
	 # Documentation: "https://alarmpaw.twown.com/#/encryption"
	 # python demo: 使用AES加密数据，并发送到服务器
	 # pip3 install pycryptodome
	 
	 import json
	 import base64
	 import requests
	 from Crypto.Cipher import AES
	 from Crypto.Util.Padding import pad
	 
	 
	 def encrypt_AES_CBC(data, key, iv):
	 cipher = AES.new(key, AES.MODE_\(cryptoConfig.mode.rawValue), iv)
	  padded_data = pad(data.encode(), AES.block_size)
	  encrypted_data = cipher.encrypt(padded_data)
	  return encrypted_data
	 
	 
	 # JSON数据
	 json_string = json.dumps({"body": "test", "sound": "birdsong"})
	 
	 # \(String(format: String(localized: "必须%d位"), Int(cryptoConfig.algorithm.name.suffix(3))! / 8))
	 key = b"\(cryptoConfig.key)"
	 # \(String(localized: "IV可以是随机生成的，但如果是随机的就需要放在 iv 参数里传递。"))
	 iv= b"\(cryptoConfig.iv)"
	 
	 # 加密
	 # \(String(localized: "控制台将打印")) "\( self.createExample() )"
	 encrypted_data = encrypt_AES_CBC(json_string, key, iv)
	 
	 # 将加密后的数据转换为Base64编码
	 encrypted_base64 = base64.b64encode(encrypted_data).decode()
	 
	 print("加密后的数据（Base64编码）：", encrypted_base64)
	 
	 deviceKey = '\(servers[0].key)'
	 
	 res = requests.get(f"\(servers[0].url)/{deviceKey}/test",
	 params = {"ciphertext": encrypted_base64, "iv": iv})
	 
	 print(res.text)
	 
	 """
		manager.copy(text)
		Toast.shared.present(title: String(localized:  "复制成功"), symbol: .copy)
		
	}
	
	func createExample()-> String{
		if let data = CryptoManager(cryptoConfig).encrypt("{\"body\": \"test\", \"sound\": \"birdsong\"}"){
			return data.base64EncodedString()
		}
		return ""
	}
	
}

#Preview {
	CryptoConfigView()
		.environment(PushupManager.shared)
}
