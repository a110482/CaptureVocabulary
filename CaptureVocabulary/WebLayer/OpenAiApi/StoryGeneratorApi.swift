//
//  StoryGeneratorApi.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2025/1/21.
//

import Foundation
import Moya

struct StoryGeneratorApi: OpenAiRequest {
    typealias ResponseModel = OpenAiSentencesModel
    typealias MessageModels = StoryDataModel
    
    var parameters: [String : Any] {[
        "model": "gpt-4o-mini",
        "response_format": [ "type": "json_object" ],
        "max_tokens": 2000,
        "messages": [
            [
                "role": "system",
                "content": requestRule
            ],
            [
                "role": "user",
                "content": "\(vocabularyList)"
            ]
        ]
    ]}
    
    var path: String = "v1/chat/completions"
    
    var method: Moya.Method = .post
    
    var vocabularyList: [String]
    
    var task: Moya.Task {
        .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    private let requestRule =
"""
給一組英文單字,用這些單字寫短文和中文翻譯,並給在故事中使用到這組單字的變化形式(若故事中無變化就給原型),使用json格式返回,以下是範例，給定:["Vibrant", "Diligent", "Mystic", "Journey", "Thrive", "Concept", "Perspective", "Clever", "Harmony", "Summit" ]則返回:
{"story": [{"article": "Embarking on a vibrant and mystical journey, a diligent traveler set out to explore new territories and gain a fresh perspective on life.","translate": "踏上充滿活力和神秘的旅程，一位勤奮的旅行者踏上了探索新領土、對生活獲得新的視角。"},{"article": "With clever planning and an open mind, the traveler sought to thrive in the unfamiliar landscapes and embrace the concept of harmony in diversity.","translate": "憑借巧妙的計劃和開放的心態，旅行者試圖在陌生的風景中茁壯成長，並擁抱多樣性中的和諧概念。"},{"article": "As the journey progressed, the traveler encountered the summit of a mountain, where the air was filled with a sense of peace and tranquility.","translate": "隨著旅程的進行，旅行者遇到了山巔，那裡的空氣充滿了和平與寧靜的感覺。"},{"article": "This experience provided a new perspective, reinforcing the concept of harmony and inspiring the traveler to thrive in all aspects of life.","translate": "這種經歷提供了一個新的視角，加強了和諧的概念，並激勵旅行者在生活的各個方面茁壯成長。"}],"vocabulary": ["Journey","Traveler","Perspective","Thrive","Concept","Harmony","Summit","Diligent","Vibrant","Clever"]}
每個句子一組，並且在 vocabulary 裡面的單字都是包含在一開始給定的單字 array 裡面
"""
}


// 定義 StoryItem 結構
struct StoryItem: Codable {
    let article: String
    let translate: String
}

// 定義主結構
struct StoryDataModel: Codable {
    let story: [StoryItem]
    let vocabulary: [String]
}
