//
//  EmailConfigModal.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//


import Foundation
import Defaults


struct EmailConfigModal{
	var smtp:String
	var email:String
	var password:String
	var toEmail:[ToEmailConfig]
	
	
	init(smtp: String, email: String, paswsword: String, toEmail: [ToEmailConfig]) {
		self.smtp = smtp
		self.email = email
		self.password = paswsword
		self.toEmail = toEmail
	}
	
   static let data = EmailConfigModal(smtp: "smtp.qq.com", email: "xxxxx@qq.com", paswsword: "123123", toEmail: [ToEmailConfig("paw@twown.com")])
	
}

extension EmailConfigModal : Codable{
	enum CodingKeys: CodingKey {
		case smtp
		case email
		case password
		case toEmail
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.smtp = try container.decode(String.self, forKey: .smtp)
		self.email = try container.decode(String.self, forKey: .email)
		self.password = try container.decode(String.self, forKey: .password)
		self.toEmail = try container.decode([ToEmailConfig].self, forKey: .toEmail)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.smtp, forKey: .smtp)
		try container.encode(self.email, forKey: .email)
		try container.encode(self.password, forKey: .password)
		try container.encode(self.toEmail, forKey: .toEmail)
	}
}


extension EmailConfigModal: RawRepresentable{
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

extension EmailConfigModal: Defaults.Serializable{ }


struct ToEmailConfig{
	var id:UUID = UUID()
	var mail:String
	
	
	init(_ mail:String){
		self.mail = mail
	}
	
	

}

extension ToEmailConfig:Codable {
	enum CodingKeys: CodingKey {
		case id
		case mail
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(UUID.self, forKey: .id)
		self.mail = try container.decode(String.self, forKey: .mail)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.mail, forKey: .mail)
	}
}

extension ToEmailConfig: Defaults.Serializable{ }
