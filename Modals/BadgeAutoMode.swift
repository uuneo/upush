//
//  BadgeAutoMode.swift
//  upush
//
//  Created by He Cho on 2024/10/8.
//
import Defaults

enum BadgeAutoMode:String, CaseIterable,Defaults.Serializable {
	case auto = "Auto"
	case custom = "Custom"
}
