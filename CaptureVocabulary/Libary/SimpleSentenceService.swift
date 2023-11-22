//
//  SimpleSenenceService.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/11/22.
//

import Moya


class SimpleSentenceService {
    static let shared = SimpleSentenceService()
    
    private var observers: [Weak] = []
    
    private var requestQueue: [String] {
        didSet { requestQueueDidChanges() }
    }
    
    private var processState: ProcessState = .padding {
        didSet { handleStatus() }
    }
    
    private enum ProcessState {
        static let defaultRetryCount = 1
        case padding
        case downloadNext
        case sendRequest(queryWord: String)
        case retry(queryWord: String, retryCount: Int)
        case complete(queryWord: String, model: OpenAiSentences.MessageModels)
    }
    
    private init() {
        requestQueue = UserDefaults.standard[UserDefaultsKeys.sentencesDownloadQueue] ?? []
        processState = .downloadNext
        handleStatus()
    }
    
    func registerObserver(object: SimpleSentenceServiceDelegate) {
        observers = observers.filter({ $0.object != nil })
        observers.append(Weak(object: object))
    }
    
    func querySentence(queryWord: String) -> [SimpleSentencesORM.ORM]? {
        if let sentences = SimpleSentencesORM.ORM.get(normalizedSource: queryWord),
           sentences.count > 0 {
            return sentences
        }
        guard !requestQueue.contains(queryWord) else {
            return nil
        }
        requestQueue.insert(queryWord, at: 0)
        return nil
    }
}

// status 流程
private extension SimpleSentenceService {
    func handleStatus() {
        print(">>> status", processState)
        switch processState {
        case .padding:
            break
        case .downloadNext:
            downloadNext()
        case .sendRequest(let queryWord):
            sendRequest(queryWord: queryWord, retryCount: ProcessState.defaultRetryCount)
        case .retry(let queryWord, let retryCount):
            sendRequest(queryWord: queryWord, retryCount: retryCount)
        case .complete(let queryWord, let model):
            complete(queryWord: queryWord, model: model)
        }
    }
    
    // 下載下一個
    func downloadNext() {
        guard requestQueue.count > 0 else {
            processState = .padding
            return
        }
        let queryWord = requestQueue.removeFirst()
        processState = .sendRequest(queryWord: queryWord)
    }
    
    // 請求例句
    func sendRequest(queryWord: String, retryCount: Int) {
        func isNeedToDownload() -> Bool {
            guard retryCount >= 0 else { return false }
            // 檢查資料庫有沒有已存資料
            guard let _ = SimpleSentencesORM.ORM.get(normalizedSource: queryWord) else {
                return false
            }
            
            // 檢查, 字典找得到字再請求例句
            guard let _ = StarDictORM.query(word: queryWord) else {
                return false
            }
            return true
        }
        
        guard isNeedToDownload() else {
            processState = .downloadNext
            return
        }
        
        let provider = MoyaProvider<OpenAiSentences>()
        provider.send(request: OpenAiSentences(queryWord: queryWord)) { result in
            guard case .success(let model) = result else {
                self.processState = .retry(queryWord: queryWord, retryCount: retryCount - 1)
                return
            }
            let message = model.choices.first?.message.content ?? ""
            let messageModel = try! JSONDecoder().decode(OpenAiSentences.MessageModels.self, from: message.data(using: .utf8)!)
            self.processState = .complete(queryWord: queryWord, model: messageModel)
        }
    }
    
    func complete(queryWord: String, model: OpenAiSentences.MessageModels) {
        // save to database
        model.sentences.forEach {
            var sentenceOrm = SimpleSentencesORM.ORM()
            sentenceOrm.normalizedSource = queryWord
            sentenceOrm.sentence = $0.sentence
            sentenceOrm.translate = $0.translate
            SimpleSentencesORM.create(sentenceOrm)
        }
        
        // notify other observer
        sentencesDidLoad(normalizedSource: queryWord)
        
        processState = .downloadNext
    }
}

private extension SimpleSentenceService {
    // 通知例句已下載
    func sentencesDidLoad(normalizedSource: String) {
        observers.forEach {
            $0.object?.sentencesDidLoad(normalizedSource: normalizedSource)
        }
    }
    
    func requestQueueDidChanges() {
        print(">>> requestQueueDidChanges", requestQueue)
        UserDefaults.standard[UserDefaultsKeys.sentencesDownloadQueue] = requestQueue
        if case .padding = processState {
            processState = .downloadNext
        }
    }
}

protocol SimpleSentenceServiceDelegate: AnyObject {
    func sentencesDidLoad(normalizedSource: String)
}

private class Weak {
    weak var object: SimpleSentenceServiceDelegate?
    init(object: SimpleSentenceServiceDelegate) {
        self.object = object
    }
}
