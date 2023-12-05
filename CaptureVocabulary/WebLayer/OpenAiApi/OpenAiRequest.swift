//
//  OpenAiRequest.swift
//  CaptureVocabulary
//
//  Created by Tan Elijah on 2023/11/20.
//

import Foundation
import Moya

protocol OpenAiRequest: Request {}

extension OpenAiRequest {
    var baseURL: URL { URL(string: "https://api.openai.com/")! }

    var headers: [String : String]? {
        let openApiKey = AppParameters.shared.model.openApiKey
        return [
         "Content-type": "application/json",
         "Authorization": "Bearer \(openApiKey)"
        ]
    }
    
    var decisions: [Decision] { [StanderDecision()] }
}

// MARK: -
struct OpenAiSentences: OpenAiRequest {
    typealias ResponseModel = OpenAiSentencesModel
    typealias MessageModels = SentencesModel
    
    var parameters: [String : Any] {[
        "model": "gpt-3.5-turbo-1106",
        "response_format": [ "type": "json_object" ],
        "max_tokens": 800,
        "messages": [
            [
                "role": "system",
                "content": requestRule
            ],
            [
                "role": "user",
                "content": "\(queryWord)"
            ]
        ]
    ]}
    
    var path: String = "v1/chat/completions"
    
    var method: Moya.Method = .post
    
    var queryWord: String
    
    var task: Moya.Task { 
        .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    private let requestRule =
"""
我給你一個英文單字
返回給我三個英文例句和對應的中文翻譯
你必須以 json 格式回應
例如
我給 "love"
你回應
{
  "sentences": [
    {
      "sentence": "I love ice cream.",
      "translate": "我喜歡冰淇淋。"
    },
    {
      "sentence": "She fell in love with a charming man.",
      "translate": "她愛上了一個迷人的男人。"
    },
    {
      "sentence": "Their love for each other grew stronger over time.",
      "translate": "他們彼此的愛隨著時間越來越深。"
    }
  ]
}
"""
}

struct SentencesModel: Codable {
    let sentences: [MessageModel]
}

struct MessageModel: Codable {
    let sentence: String
    let translate: String
}


struct OpenAiSentencesModel: Codable {
    let model: String
    let choices: [ChatChoice]
    let usage: Usage
    
    struct ChatChoice: Codable {
        let index: Int
        let message: ChatMessage
        let finishReason: String
        
        private enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }

    struct ChatMessage: Codable {
        let role: String
        let content: String
    }

    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        private enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}


