//
//  AudioManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import AVKit
import Combine


/// 用于将铃声文件保存在 /Library/Sounds 文件夹中
class AudioManager:ObservableObject{
	static let shared =  AudioManager()
	
	@Published var defaultSounds:[URL] =  []
	@Published var customSounds:[URL] =  []
	
	private let appGroupIdentifier = BaseConfig.groupName

	private var customSoundsDirectoryMonitor: DispatchSourceFileSystemObject?
	private let manager = FileManager.default
	
	
	private init() {
		getFileList()
	}
	
	private func getFileList() {
		let defaultSounds:[URL] = {
			var temurl = Bundle.main.urls(forResourcesWithExtension: "caf", subdirectory: nil) ?? []
			temurl.sort { u1, u2 -> Bool in
				u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
			}
			return temurl
		}()
		
		let customSounds: [URL] = {
			let soundsDirectoryUrl = getSoundsDirectory()
			var urlemp = self.getFilesInDirectory(directory: soundsDirectoryUrl.path(), suffix: "caf")
			urlemp.sort { u1, u2 -> Bool in
				u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
			}
			
			return urlemp
		}()
		
		DispatchQueue.main.async {
			self.customSounds = customSounds
			self.defaultSounds = defaultSounds
		}
		
	}
	
	/// 返回指定文件夹，指定后缀的文件列表数组
	func getFilesInDirectory(directory: String, suffix: String) -> [URL] {

		do {
			let files = try manager.contentsOfDirectory(atPath: directory)
			return files.compactMap { file -> URL? in
				if file.hasSuffix(suffix) {
					return URL(fileURLWithPath: directory).appendingPathComponent(file)
				}
				return nil
			}
		} catch {
			return []
		}
	}
	
	
	/// 将指定文件保存在 Library/Sound，如果存在则覆盖
	func saveSound(url: URL) {
		let soundsDirectoryUrl = getSoundsDirectory()
		saveFile(to: soundsDirectoryUrl, from: url)
		saveSoundToGroupDirectory(url: url)
		getFileList()
	}

	func deleteSound(url: URL) {
		// 删除sounds目录铃声文件
		try? manager.removeItem(at: url)
		// 删除共享目录中的文件
		if let groupSoundUrl = getSoundsGroupDirectory()?.appendingPathComponent(url.lastPathComponent) {
			try? manager.removeItem(at: groupSoundUrl)
		}
		getFileList()
	}
	
	/// 获取 Library 目录下的 Sounds 文件夹
	/// 如果不存在就创建
	private func getSoundsDirectory() -> URL {
		let soundFolderPath = manager.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent(BaseConfig.Sounds)
		
		var isDirectory: ObjCBool = false
		
		if !manager.fileExists(atPath: soundFolderPath.path, isDirectory: &isDirectory) || !isDirectory.boolValue{
			try? manager.createDirectory(at: soundFolderPath, withIntermediateDirectories: true, attributes: nil)
		}
		
		return soundFolderPath
	}

	/// 保存到共享文件夹，供 NotificationServiceExtension 使用
	private func saveSoundToGroupDirectory(url: URL) {
		if let groupDirectoryUrl = getSoundsGroupDirectory() {
			saveFile(to: groupDirectoryUrl, from: url)
		}
	}
	
	/// 获取共享目录下的 Sounds 文件夹，如果不存在就创建
	private func getSoundsGroupDirectory() -> URL? {
		if let directoryUrl = manager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?.appendingPathComponent(BaseConfig.Sounds) {
			if !manager.fileExists(atPath: directoryUrl.path) {
				try? manager.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
			}
			return directoryUrl
		}
		return nil
	}

	

	/// 通用文件保存方法
	private func saveFile(to directoryUrl: URL, from sourceUrl: URL) {
		let destinationUrl = directoryUrl.appendingPathComponent(sourceUrl.lastPathComponent)
		if manager.fileExists(atPath: destinationUrl.path) {
			try? manager.removeItem(at: destinationUrl)
		}
		try? manager.copyItem(at: sourceUrl, to: destinationUrl)
	}
	
}
