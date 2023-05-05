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
        Self.workSpace?.appendingPathComponent("resource.db", conformingTo: .item)
    }
    fileprivate let db: Connection
    
    
    private init() {
        Self.copyDB()
        db = try! Connection(Self.dbUrl!.path)
    }
    
    func test() {
        let res = StarDictORM.query(word: "message")
        print(">>>", res)
    }
    
    private static func copyDB() {
        guard let allBundleSources = try? fileManager.contentsOfDirectory(at: Bundle.main.bundleURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
        guard let zip = allBundleSources.first(where: { $0.path.contains("Resource.zip")}) else { return }
        guard let defaultUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let workSpace = defaultUrl.appendingPathComponent("workSpace", conformingTo: .folder)
        let dbUrl = workSpace.appendingPathComponent("resource.db", conformingTo: .item)
        
        if !fileManager.fileExists(atPath: dbUrl.path) {
            SSZipArchive.unzipFile(atPath: zip.path, toDestination: workSpace.path)
        }
    }
}

/// 僅提供查詢
struct StarDictORM {
    static let table = Table("stardict")
    static let id = Expression<Int64>("id")
    static let word = Expression<String>("word")
    static let phonetic = Expression<String>("phonetic")
    static let translation = Expression<String>("translation")
    
    struct ORM: ORMProtocol {
        var id: Int64?
        var word: String?
        var phonetic: String?
        var translation: String?
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
}

