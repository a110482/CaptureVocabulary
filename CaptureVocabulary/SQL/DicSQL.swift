//
//  DicSQL.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/5/4.
//

import Foundation
import SQLite
import SSZipArchive

class DicSQL {
    static let shared = DicSQL()
    private static let fileManager = FileManager.default
    private static var workSpace: URL? {
        guard let defaultUrl = Self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return defaultUrl.appendingPathComponent("workSpace", conformingTo: .folder)
    }
    private static var dbUrl: URL? {
        Self.workSpace?.appendingPathComponent("ecdict.db", conformingTo: .item)
    }
    fileprivate let db: Connection
    
    
    private init() {
        Self.copyDB()
        // 第一次 run 專案在這裡發生錯誤
        // 通常是因為 git 沒有拉到 Resource.zip
        // 請確認安裝 https://git-lfs.com/
        // 並在專案內資料夾找到 CaptureVocabulary/Resource.zip
        // 其大小應該為 60mb 左右, 如果只有幾百 kb 那就是沒有拉到
        db = try! Connection(Self.dbUrl!.path)
    }
    
    private static func copyDB() {
        guard let allBundleSources = try? fileManager.contentsOfDirectory(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        guard let zip = allBundleSources.first(where: { $0.path.contains("Resource.zip")}) else { return }
        guard let workSpace = workSpace, let dbUrl = dbUrl else { return }
        
        if !fileManager.fileExists(atPath: dbUrl.path) {
            SSZipArchive.unzipFile(atPath: zip.path, toDestination: workSpace.path)
        }
    }
    
    #if DEBUG
    func test() {
        
    }
    #endif
}

/// 僅提供查詢
struct StarDictORM {
    static let table = Table("stardict")
    static let id = Expression<Int64>("id")
    static let word = Expression<String>("word")
    static let phonetic = Expression<String>("phonetic")
    static let translation = Expression<String>("translation")
    static let sw = Expression<String>("sw")
    
    struct ORM: ORMProtocol {
        var id: Int64?
        var word: String?
        var phonetic: String?
        var translation: String?
        var sw: String?
        
        func getMainTranslation() -> String? {
            guard let translation = translation,
                  !translation.isEmpty else { return nil }
            guard let firstLine = translation.split(separator: "\n").first else { return nil }
            guard let firstWord = firstLine.split(whereSeparator: {
                return [",", ";", "；"].contains($0)
            }).first else { return nil }
            // 移除括號內文字 ex: abc(def) => abc
            var refineWord = refineWords(source: String(firstWord))
            return refineWord
        }
        
        // 移除括號內文字 ex: abc(def) => abc
        private func refineWords(source: String) -> String {
            var refineWord = ""
            var isRemove = false
            for char in source {
                if ["(", "（", "["].contains(char) {
                    isRemove = true
                } else if [")", "）", "]"].contains(char) {
                    isRemove = false
                } else if !isRemove {
                    refineWord.append(char)
                }
            }
            return refineWord
        }
    }
    
    static func query(word: String) -> ORM? {
        let result = try? DicSQL.shared.db.prepare(
            table.filter(Self.word == word).limit(1)
        )
        do {
            return try result?.map({ try $0.decode() }).first
        } catch {
            return nil
        }
    }
    
    /// 模糊比對查詢
    static func match(word: String, limit: Int = 10) -> [ORM]? {
        let result = try? DicSQL.shared.db.prepare(
            table.filter(Self.sw >= word)
                .order([sw, word])
                .limit(limit)
        )
        do {
            return try result?.map({ try $0.decode() })
        } catch {
            return nil
        }
    }
}

//ecdict.db
