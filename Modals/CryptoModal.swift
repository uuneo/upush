//
//  CryptoModal.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//
import Defaults
import Foundation


enum CryptoMode: String, Codable,CaseIterable, RawRepresentable, Defaults.Serializable {
	
	case CBC, ECB, GCM
	var padding: String {
		self == .GCM ? "Space" : "PKCS7"
	}

	
}

enum CryptoAlgorithm: Int, Codable, CaseIterable,RawRepresentable, Defaults.Serializable {
	case AES128 = 16 // 16 bytes = 128 bits
	case AES192 = 24 // 24 bytes = 192 bits
	case AES256 = 32 // 32 bytes = 256 bits
	
	var name:String{
		self == .AES128 ? "AES128" : (self == .AES192 ? "AES192" : "AES256")
	}
}



struct CryptoModal: Equatable{
	
	var algorithm: CryptoAlgorithm
	var mode: CryptoMode
	var key: String
	var iv: String
	
	static let data = CryptoModal(algorithm: .AES256, mode: .GCM, key: generateRandomString(), iv: generateRandomString(by32: false))
	
	
	static func generateRandomString(by32:Bool = true) -> String {
		// 创建可用字符集（大写、小写字母和数字）
		let charactersArray = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
		
		return String(Array(1...(by32 ? 32 : 16)).compactMap { _ in charactersArray.randomElement() })
	}
	
}

extension CryptoModal: Codable{
	enum CodingKeys: String, CodingKey{
		case algorithm
		case mode
		case key
		case iv
	}
	
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(algorithm, forKey: .algorithm)
		try container.encodeIfPresent(mode, forKey: .mode)
		try container.encodeIfPresent(key, forKey: .key)
		try container.encodeIfPresent(iv, forKey: .iv)
	}

	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.algorithm = try container.decode(CryptoAlgorithm.self, forKey: .algorithm)
		self.mode = try container.decode(CryptoMode.self, forKey: .mode)
		self.key = try container.decode(String.self, forKey: .key)
		self.iv = try container.decode(String.self, forKey: .iv)
	}
	
}


extension CryptoModal: RawRepresentable{
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8) ,
			  let result = try? JSONDecoder().decode(
				Self.self,from: data) else{
			return nil
		}
		self = result
	}

	public var rawValue: String {
		guard let result = try? JSONEncoder().encode(self),
			  let string = String(data: result, encoding: .utf8) else{
			return ""
		}
		return string
	}
	
}

extension CryptoModal: Defaults.Serializable {}

