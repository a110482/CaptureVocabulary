//
//  StoryORM.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/23.
//

import Foundation
import SQLite



struct StoryORM: TableType {
    static let table = Table("story")
    static let id = SQLite.Expression<Int64>("id")
    static let timestamp = SQLite.Expression<Double>("timestamp")
    static let storyDataModelJsonString = SQLite.Expression<String>("storyDataModelJsonString")
    
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var timestamp: TimeInterval = Date().timeIntervalSince1970
        var storyDataModelJsonString: String
        
        init?(storyDataModel: StoryDataModel) {
            guard let storyDataModelJsonString = storyDataModel.jsonString else {
                return nil
            }
            self.storyDataModelJsonString = storyDataModelJsonString
        }
        
        func getStoryDataModel() -> StoryDataModel? {
            guard let data = storyDataModelJsonString.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(StoryGeneratorApi.MessageModels.self, from: data)
        }
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(timestamp)
                t.column(storyDataModelJsonString)
            })
            
            Story_VocabularyORM.createTable()
        }
        catch {
            print(error)
        }
    }
}

extension StoryORM.ORM {
    typealias ORMModel = StoryORM
    
    func getAllVocabularyCard() -> [VocabularyCardORM.ORM] {
        guard let id else { return [] }
        let query = Story_VocabularyORM.table.filter(Story_VocabularyORM.storyId == id)
        
        let allStory_Vocabulary = Story_VocabularyORM.prepare(query) ?? []
        let allVocabularyIds = allStory_Vocabulary.map({ $0.vocabularyCardId })
        let allVocabulary = allVocabularyIds.compactMap({
            let query = VocabularyCardORM.table
                .filter(VocabularyCardORM.id == $0)
                .limit(1)
            return VocabularyCardORM.prepare(query)?.first
        })
        return allVocabulary
    }
    
    func save(with vocabularyCards: [VocabularyCardORM.ORM]) {
        StoryORM.create(self)
        let query = StoryORM.table.order(StoryORM.id.desc).limit(1)
        guard let storyId = StoryORM.prepare(query)?.first?.id else { return }
        
        let vocabularyIds = vocabularyCards.compactMap({ $0.id })
        for vocabularyId in vocabularyIds {
            let story_VocabularyObject = Story_VocabularyORM.ORM(
                storyId: storyId,
                vocabularyCardId: vocabularyId)
            Story_VocabularyORM.create(story_VocabularyObject)
        }
    }
    
    static func getAllStory() -> [Self]? {
        let query = ORMModel.table.order(ORMModel.id.desc)
        return ORMModel.prepare(query)
    }
    
    static func getLastStory() -> Self? {
        let query = ORMModel.table.order(ORMModel.id.desc).limit(1)
        return ORMModel.prepare(query)?.first
    }
}

// MARK: - Story_VocabularyORM
fileprivate struct Story_VocabularyORM: TableType {
    static let table = Table("story_vocabulary")
    /// 此表採用複合主鍵，不使用 id
    static let id = SQLite.Expression<Int64>("id")
    static let storyId = SQLite.Expression<Int64>("storyId")
    static let vocabularyCardId = SQLite.Expression<Int64>("vocabularyCardId")
    
    struct ORM: ORMProtocol {
        var id: Int64? = nil
        var storyId: Int64
        var vocabularyCardId: Int64
    }
    
    static func createTable(db: Connection = SQLCore.shared.db) {
        do {
            let _ = try db.run(Self.table.create(ifNotExists: true) { t in
                t.column(storyId)
                t.column(vocabularyCardId)
                t.primaryKey(storyId, vocabularyCardId)
                t.foreignKey(storyId,
                             references: StoryORM.table,
                             id,
                             delete: .restrict)
                t.foreignKey(vocabularyCardId,
                             references: VocabularyCardORM.table,
                             id,
                             delete: .restrict)
            })
        }
        catch {
            print(error)
        }
    }
}
