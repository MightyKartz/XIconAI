//
//  StorageService.swift
//  Icons
//
//  Created by kartz on 2025/1/11.
//

import Foundation
import SwiftUI

/// 本地存储服务
class StorageService: ObservableObject {
    static let shared = StorageService()
    
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // MARK: - 存储路径
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var templatesDirectory: URL {
        documentsDirectory.appendingPathComponent("Templates")
    }
    
    private var historyDirectory: URL {
        documentsDirectory.appendingPathComponent("History")
    }
    
    private var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Icons")
    }
    
    private init() {
        createDirectoriesIfNeeded()
    }
    
    // MARK: - 目录管理
    private func createDirectoriesIfNeeded() {
        let directories = [templatesDirectory, historyDirectory, cacheDirectory]
        
        for directory in directories {
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
        }
    }
    
    // MARK: - 模板存储
    func saveTemplate(_ template: PromptTemplate) throws {
        let fileName = "\(template.id.uuidString).json"
        let fileURL = templatesDirectory.appendingPathComponent(fileName)
        
        let data = try JSONEncoder().encode(template)
        try data.write(to: fileURL)
    }
    
    func loadTemplates() throws -> [PromptTemplate] {
        let fileURLs = try fileManager.contentsOfDirectory(at: templatesDirectory, 
                                                          includingPropertiesForKeys: nil)
        
        var templates: [PromptTemplate] = []
        
        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            let data = try Data(contentsOf: fileURL)
            let template = try JSONDecoder().decode(PromptTemplate.self, from: data)
            templates.append(template)
        }
        
        return templates.sorted { $0.name < $1.name }
    }
    
    func deleteTemplate(_ template: PromptTemplate) throws {
        let fileName = "\(template.id.uuidString).json"
        let fileURL = templatesDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    // MARK: - 历史记录存储
    func saveGeneratedIcon(_ icon: GeneratedIcon) throws {
        let fileName = "\(icon.id.uuidString).json"
        let fileURL = historyDirectory.appendingPathComponent(fileName)
        
        let data = try JSONEncoder().encode(icon)
        try data.write(to: fileURL)
    }
    
    func loadGeneratedIcons() throws -> [GeneratedIcon] {
        let fileURLs = try fileManager.contentsOfDirectory(at: historyDirectory, 
                                                          includingPropertiesForKeys: nil)
        
        var icons: [GeneratedIcon] = []
        
        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            let data = try Data(contentsOf: fileURL)
            let icon = try JSONDecoder().decode(GeneratedIcon.self, from: data)
            icons.append(icon)
        }
        
        return icons.sorted { $0.createdAt > $1.createdAt }
    }
    
    func deleteGeneratedIcon(_ icon: GeneratedIcon) throws {
        let fileName = "\(icon.id.uuidString).json"
        let fileURL = historyDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        
        // 同时删除缓存的图片文件
        if let imageURL = getCachedImageURL(for: icon.id) {
            try? fileManager.removeItem(at: imageURL)
        }
        // 同时删除缓存的缩略图文件
        if let thumbURL = getCachedThumbnailURL(for: icon.id) {
            try? fileManager.removeItem(at: thumbURL)
        }
    }
    
    // MARK: - 图片缓存
    func cacheImage(_ imageData: Data, for iconID: UUID) throws -> URL {
        let fileName = "\(iconID.uuidString).png"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try imageData.write(to: fileURL)
        return fileURL
    }
    
    func getCachedImageURL(for iconID: UUID) -> URL? {
        let fileName = "\(iconID.uuidString).png"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    // 新增：缩略图路径（保存用）
    func getThumbnailSaveURL(for iconID: UUID) -> URL {
        let fileName = "\(iconID.uuidString)_thumb.png"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    // 新增：缩略图路径（读取用）
    func getCachedThumbnailURL(for iconID: UUID) -> URL? {
        let fileName = "\(iconID.uuidString)_thumb.png"
        let url = cacheDirectory.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: url.path) ? url : nil
    }
    
    func getCachedImageData(for iconID: UUID) -> Data? {
        guard let url = getCachedImageURL(for: iconID) else { return nil }
        return try? Data(contentsOf: url)
    }
    
    func clearImageCache() throws {
        let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, 
                                                          includingPropertiesForKeys: nil)
        
        for fileURL in fileURLs {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    // MARK: - 设置存储
    func saveAppState() async {
        await MainActor.run {
            AppState.shared.saveSettings()
        }
    }
    
    func loadAppState() {
        // AppState 已经有自己的 loadSettings 方法
        // 这个方法在 AppState 初始化时自动调用
    }
    
    // MARK: - 导入导出
    func exportTemplates(to url: URL) throws {
        let templates = try loadTemplates()
        let data = try JSONEncoder().encode(templates)
        try data.write(to: url)
    }
    
    func importTemplates(from url: URL) throws -> [PromptTemplate] {
        let data = try Data(contentsOf: url)
        let templates = try JSONDecoder().decode([PromptTemplate].self, from: data)
        
        // 保存导入的模板
        for template in templates {
            try saveTemplate(template)
        }
        
        return templates
    }
    
    func exportHistory(to url: URL) throws {
        let icons = try loadGeneratedIcons()
        let data = try JSONEncoder().encode(icons)
        try data.write(to: url)
    }
    
    // 修改为 async，先在主线程获取快照，再在后台线程写文件
    func exportSettings(to url: URL) async throws {
        let snapshot: (imageQuality: String, generationCount: Int, autoOptimizePrompts: Bool, exportFolderPath: String, filenameTemplate: String) = await MainActor.run {
            (
                imageQuality: AppState.shared.imageQuality.rawValue,
                generationCount: AppState.shared.generationCount,
                autoOptimizePrompts: AppState.shared.autoOptimizePrompts,
                exportFolderPath: AppState.shared.exportFolderPath,
                filenameTemplate: AppState.shared.filenameTemplate
            )
        }

        let settingsDict: [String: Any] = [
            "imageQuality": snapshot.imageQuality,
            "generationCount": snapshot.generationCount,
            "autoOptimizePrompts": snapshot.autoOptimizePrompts,
            "exportFolderPath": snapshot.exportFolderPath,
            "filenameTemplate": snapshot.filenameTemplate
        ]
        let data = try JSONSerialization.data(withJSONObject: settingsDict)
        try data.write(to: url)
    }
    
    // 修改为 async：先读取文件，再到主线程更新 AppState
    func importSettings(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let settingsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        await MainActor.run {
            if let qualityRaw = settingsDict?["imageQuality"] as? String,
               let quality = ImageQuality(rawValue: qualityRaw) {
                AppState.shared.imageQuality = quality
            }

            if let count = settingsDict?["generationCount"] as? Int {
                AppState.shared.generationCount = count
            }

            if let autoOptimize = settingsDict?["autoOptimizePrompts"] as? Bool {
                AppState.shared.autoOptimizePrompts = autoOptimize
            }

            if let exportPath = settingsDict?["exportFolderPath"] as? String {
                AppState.shared.exportFolderPath = exportPath
            }

            if let template = settingsDict?["filenameTemplate"] as? String {
                AppState.shared.filenameTemplate = template
            }

            AppState.shared.saveSettings()
        }
    }
    
    // MARK: - 统计信息
    func getStorageInfo() -> StorageInfo {
        let templatesCount = (try? loadTemplates().count) ?? 0
        let historyCount = (try? loadGeneratedIcons().count) ?? 0
        
        let cacheSize = getCacheSize()
        let totalSize = getTotalSize()
        
        return StorageInfo(
            templatesCount: templatesCount,
            historyCount: historyCount,
            cacheSize: cacheSize,
            totalSize: totalSize
        )
    }
    
    private func getCacheSize() -> Int64 {
        guard let enumerator = fileManager.enumerator(at: cacheDirectory, 
                                                     includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    private func getTotalSize() -> Int64 {
        let directories = [templatesDirectory, historyDirectory, cacheDirectory]
        var totalSize: Int64 = 0
        
        for directory in directories {
            guard let enumerator = fileManager.enumerator(at: directory, 
                                                         includingPropertiesForKeys: [.fileSizeKey]) else {
                continue
            }
            
            for case let fileURL as URL in enumerator {
                if let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
            }
        }
        
        return totalSize
    }
    
    // MARK: - 清理功能
    func clearAllData() async throws {
        // 清除模板
        let templateFiles = try fileManager.contentsOfDirectory(at: templatesDirectory,
                                                               includingPropertiesForKeys: nil)
        for file in templateFiles {
            try fileManager.removeItem(at: file)
        }

        // 清除历史记录
        let historyFiles = try fileManager.contentsOfDirectory(at: historyDirectory,
                                                              includingPropertiesForKeys: nil)
        for file in historyFiles {
            try fileManager.removeItem(at: file)
        }

        // 清除缓存
        try clearImageCache()

        // 在主线程重置 AppState 设置
        await MainActor.run {
            AppState.shared.imageQuality = .high
            AppState.shared.generationCount = 4
            AppState.shared.autoOptimizePrompts = true
            AppState.shared.exportFolderPath = ""
            AppState.shared.filenameTemplate = "icon_{timestamp}"
            AppState.shared.saveSettings()
        }
    }
}

/// 存储信息结构体
struct StorageInfo {
    let templatesCount: Int
    let historyCount: Int
    let cacheSize: Int64
    let totalSize: Int64
    
    var cacheSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: cacheSize, countStyle: .file)
    }
    
    var totalSizeFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
}

/// 存储错误枚举
enum StorageError: LocalizedError {
    case fileNotFound
    case invalidData
    case writeError
    case readError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "文件未找到"
        case .invalidData:
            return "数据格式无效"
        case .writeError:
            return "写入文件失败"
        case .readError:
            return "读取文件失败"
        }
    }
}