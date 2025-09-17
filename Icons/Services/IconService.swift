//
//  IconService.swift
//  Icons
//
//  Created by Icons App on 2024/01/01.
//

import Foundation
import SwiftUI
import AppKit

/// 图标管理服务
class IconService: ObservableObject {
    static let shared = IconService()
    
    @Published var generatedIcons: [GeneratedIcon] = []
    @Published var favoriteIcons: [GeneratedIcon] = []
    
    private let storageService = StorageService.shared
    private let maxHistoryCount = 100
    private let exportService = ExportService.shared
    
    private init() {
        loadIcons()
    }
    
    // MARK: - 图标管理
    
    /// 添加新生成的图标
    func addIcon(_ icon: GeneratedIcon) {
        generatedIcons.insert(icon, at: 0)

        // 限制历史记录数量
        if generatedIcons.count > maxHistoryCount {
            generatedIcons = Array(generatedIcons.prefix(maxHistoryCount))
        }

        saveIcons()

        // 同步到 AppState
        Task { @MainActor in
            AppState.shared.generatedIcons.insert(icon, at: 0)
            // 限制 AppState 中的历史记录数量
            if AppState.shared.generatedIcons.count > maxHistoryCount {
                AppState.shared.generatedIcons = Array(AppState.shared.generatedIcons.prefix(maxHistoryCount))
            }
        }

        // 后台准备本地缓存与缩略图
        Task { [weak self] in
            guard let self = self else { return }
            await self.prepareLocalCache(for: icon)
        }
    }
    
    /// 删除图标
    func deleteIcon(_ icon: GeneratedIcon) {
        // 先删除持久化文件（JSON/缓存图/缩略图）
        do { try storageService.deleteGeneratedIcon(icon) } catch { print("删除持久化图标失败: \(error)") }

        generatedIcons.removeAll { $0.id == icon.id }
        favoriteIcons.removeAll { $0.id == icon.id }
        saveIcons()

        // 同步到 AppState
        Task { @MainActor in
            AppState.shared.generatedIcons.removeAll { $0.id == icon.id }
        }
    }
    
    /// 添加到收藏
    func addToFavorites(_ icon: GeneratedIcon) {
        if !favoriteIcons.contains(where: { $0.id == icon.id }) {
            favoriteIcons.append(icon)
            saveIcons()
        }
    }
    
    /// 从收藏中移除
    func removeFromFavorites(_ icon: GeneratedIcon) {
        favoriteIcons.removeAll { $0.id == icon.id }
        saveIcons()
    }
    
    /// 检查是否已收藏
    func isFavorite(_ icon: GeneratedIcon) -> Bool {
        return favoriteIcons.contains { $0.id == icon.id }
    }
    
    /// 清空历史记录
    func clearHistory() {
        generatedIcons.removeAll()
        saveIcons()

        // 同步到 AppState
        Task { @MainActor in
            AppState.shared.generatedIcons.removeAll()
        }
    }
    
    /// 清空收藏
    func clearFavorites() {
        favoriteIcons.removeAll()
        saveIcons()
    }
    
    // MARK: - 搜索和筛选
    
    /// 搜索图标
    func searchIcons(query: String) -> [GeneratedIcon] {
        guard !query.isEmpty else { return generatedIcons }
        
        return generatedIcons.filter { icon in
            icon.prompt.localizedCaseInsensitiveContains(query) ||
            icon.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    /// 按风格筛选
    func filterIcons(by style: IconStyle?) -> [GeneratedIcon] {
        guard let style = style else { return generatedIcons }
        return generatedIcons.filter { icon in
            icon.tags.contains(style.rawValue)
        }
    }
    
    /// 按日期筛选
    func filterIcons(from startDate: Date, to endDate: Date) -> [GeneratedIcon] {
        return generatedIcons.filter { icon in
            icon.createdAt >= startDate && icon.createdAt <= endDate
        }
    }
    
    // MARK: - 统计信息
    
    /// 获取生成统计
    func getGenerationStats() -> GenerationStats {
        let totalCount = generatedIcons.count
        let favoriteCount = favoriteIcons.count
        
        // 统计标签使用情况
        let allTags = generatedIcons.flatMap { $0.tags }
        let tagStats = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
        
        let recentCount = generatedIcons.filter { icon in
            Calendar.current.isDateInToday(icon.createdAt)
        }.count
        
        return GenerationStats(
            totalGenerated: totalCount,
            totalFavorites: favoriteCount,
            generatedToday: recentCount,
            tagBreakdown: tagStats
        )
    }
    
    // MARK: - 数据持久化
    
    private func saveIcons() {
        do {
            // 保存生成的图标到历史记录
            for icon in generatedIcons {
                try storageService.saveGeneratedIcon(icon)
            }
            
            // 收藏图标通过UserDefaults保存
            let favoritesData = try JSONEncoder().encode(favoriteIcons)
            UserDefaults.standard.set(favoritesData, forKey: "favorite_icons")
        } catch {
            print("保存图标数据失败: \(error)")
        }
    }
    
    func loadIcons() {
        do {
            // 从StorageService加载生成的图标
            generatedIcons = try storageService.loadGeneratedIcons()

            // 从UserDefaults加载收藏图标
            if let favoritesData = UserDefaults.standard.data(forKey: "favorite_icons") {
                favoriteIcons = try JSONDecoder().decode([GeneratedIcon].self, from: favoritesData)
            }

            // 同步到 AppState
            Task { @MainActor in
                AppState.shared.generatedIcons = generatedIcons
            }
        } catch {
            print("加载图标数据失败: \(error)")
            generatedIcons = []
            favoriteIcons = []

            // 同步到 AppState
            Task { @MainActor in
                AppState.shared.generatedIcons = []
            }
        }
    }
    
    // MARK: - 自动清理（7 天保留）
    /// 若当天未执行过，则执行一次 7 天自动清理
    func runDailyCleanupIfNeeded() {
        let defaults = UserDefaults.standard
        if let last = defaults.object(forKey: "last_cleanup_date") as? Date,
           Calendar.current.isDateInToday(last) {
            return
        }
        
        Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            await self.performCleanup(olderThanDays: 7)
            defaults.set(Date(), forKey: "last_cleanup_date")
        }
    }
}

// MARK: - 数据模型

/// 生成统计信息
struct GenerationStats {
    let totalGenerated: Int
    let totalFavorites: Int
    let generatedToday: Int
    let tagBreakdown: [String: Int]
}

// MARK: - 私有辅助方法
private extension IconService {
    @MainActor
    func updateIcon(_ updated: GeneratedIcon) {
        if let idx = generatedIcons.firstIndex(where: { $0.id == updated.id }) {
            generatedIcons[idx] = updated
        }
        // 持久化单个更新
        do { try storageService.saveGeneratedIcon(updated) } catch { print("保存更新图标失败: \(error)") }
    }
    
    func prepareLocalCache(for icon: GeneratedIcon) async {
        // 若已有本地路径且文件存在，则仅考虑缩略图生成
        var localPath: String? = icon.localPath
        let fm = FileManager.default
        if let lp = localPath, fm.fileExists(atPath: lp) == false {
            localPath = nil
        }
        
        // 下载并缓存原图
        if localPath == nil, let url = URL(string: icon.imageURL) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let fileURL = try storageService.cacheImage(data, for: icon.id)
                localPath = fileURL.path
            } catch {
                print("下载或缓存原图失败: \(error)")
            }
        }
        
        // 从主线程快照配置
        let (shouldGenerateThumb, compression): (Bool, Double) = await MainActor.run {
            (AppState.shared.generateThumbnails, AppState.shared.pngCompressionLevel)
        }
        
        // 生成缩略图（可选）
        var thumbPath: String? = icon.thumbnailPath
        if shouldGenerateThumb {
            do {
                // 基于已有数据或本地文件创建 NSImage
                var image: NSImage?
                if let lp = localPath {
                    image = NSImage(contentsOfFile: lp)
                } else if let url = URL(string: icon.imageURL) {
                    if let data = try? Data(contentsOf: url) {
                        image = NSImage(data: data)
                    }
                }
                if image != nil {
                    // 统一缩略图尺寸，保证网格/列表清晰
                    let target = CGSize(width: 160, height: 160)
                    let saveURL = storageService.getThumbnailSaveURL(for: icon.id)
                    try await exportService.exportIcon(
                        icon,
                        to: saveURL,
                        format: .png,
                        size: target,
                        compressionQuality: compression
                    )
                    thumbPath = saveURL.path
                }
            } catch {
                print("生成缩略图失败: \(error)")
            }
        }
        
        // 若无变化则无需更新
        if localPath == icon.localPath && thumbPath == icon.thumbnailPath { return }
        
        // 生成携带路径的新模型并在主线程更新
        let updated = GeneratedIcon(
            id: icon.id,
            prompt: icon.prompt,
            templateId: icon.templateId,
            imageURL: icon.imageURL,
            localPath: localPath,
            thumbnailPath: thumbPath,
            size: icon.size,
            format: icon.format,
            createdAt: icon.createdAt,
            model: icon.model,
            parameters: icon.parameters,
            isFavorite: icon.isFavorite,
            tags: icon.tags
        )
        await MainActor.run { [weak self] in
            self?.updateIcon(updated)
        }
    }
    
    /// 执行过期历史清理（默认 7 天）
    func performCleanup(olderThanDays: Int) async {
        let cutoff = Calendar.current.date(byAdding: .day, value: -olderThanDays, to: Date()) ?? Date.distantPast
        
        // 在主线程快照需要清理的对象
        let expired: [GeneratedIcon] = await MainActor.run { [generatedIcons] in
            return generatedIcons.filter { $0.createdAt < cutoff }
        }
        
        guard !expired.isEmpty else { return }
        
        // 逐个删除持久化文件
        for icon in expired {
            do { try storageService.deleteGeneratedIcon(icon) } catch { print("自动清理删除失败: \(error)") }
        }
        
        // 更新内存与持久化
        await MainActor.run {
            let expiredIDs = Set(expired.map { $0.id })
            self.generatedIcons.removeAll { expiredIDs.contains($0.id) }
            self.favoriteIcons.removeAll { expiredIDs.contains($0.id) }
            self.saveIcons()
        }
    }
}