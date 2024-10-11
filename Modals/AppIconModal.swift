//
//  Appicon.swift
//  Pushup
//
//  Created by He Cho on 2024/10/8.
//

import Foundation
import Defaults

enum AppIconEnum:String, CaseIterable,Equatable,Defaults.Serializable{
	case def = "AppIcon"
	case zero = "AppIcon0"
	case one = "AppIcon1"
	case two = "AppIcon2"
	
	var logo: String{
		switch self {
		case .def:
			"logo"
		case .zero:
			"logo0"
		case .one:
			"logo1"
		case .two:
			"logo2"
		}
	}
}

