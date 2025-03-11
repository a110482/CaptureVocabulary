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
給一組英文單字,用這些單字寫短文和中文翻譯,並給在故事中使用到這組單字的變化形式,使用json格式返回,以下是範例，給定種子單字清單:["efficiency", "motivation", "negotiate", "guidance", "decision", "effect", "training", "scheduling", "investment", "qualification", "undecidable", "elect", "supervisor", "communication", "authorization", "coordination", "benefit", "experience", "consultation", "contract", "effective", "elder", "analysis", "requirement", "conference", "planning", "achievement", "collaboration", "presentation", "operation"]
則返回:
{"title" : {
    "en" : "The Effective Path to Achievement",
    "ch" : "通往成就的有效途徑"
  },
  "story" : [
    {
      "article" : "In a conference room filled with eager minds, the supervisor emphasized the importance of efficiency and how it can lead to significant achievements.",
      "translate" : "在一個充滿渴望心靈的會議室中，監督強調了效率的重要性以及它如何能帶來重大的成就。"
    },
    {
      "article" : "Motivation was high as the team engaged in training sessions that provided guidance on effective communication skills and negotiation tactics.",
      "translate" : "隨著團隊參加提供有效溝通技巧和談判策略指導的訓練課程，士氣高漲。"
    },
    {
      "article" : "After thorough analysis, they had to make a decision on scheduling a follow-up presentation and securing the necessary authorization for their project.",
      "translate" : "經過詳細的分析，他們必須在安排後續報告和確保其項目所需的授權方面做出決定。"
    },
    {
      "article" : "The process allowed for effective collaboration among members, ensuring that everyone's input was valuable, thereby benefiting the overall operation.",
      "translate" : "這個過程使成員之間的有效合作得以實現，確保每個人的意見都是有價值的，從而使整體運作受益。"
    },
    {
      "article" : "Ultimately, the investment in training and the careful consideration of requirements led to an undeniable experience of success.",
      "translate" : "最終，對訓練的投資以及對需求的仔細考量導致了一種無可否認的成功經歷。"
    }
  ],
  "vocabulary" : [
    "Efficiency",
    "Motivation",
    "Supervisor",
    "Training",
    "Guidance",
    "Communication",
    "Negotiation",
    "Decision",
    "Analysis",
    "Scheduling",
    "Presentation",
    "Authorization",
    "Operation",
    "Collaboration",
    "Benefit",
    "Benefiting",
    "Investment",
    "Requirement",
    "Experience",
    "Effective",
    "Achievement",
    "Achievements"
    "Conference"
  ]
}
每個句子一組，並且在返回的 vocabulary array 裡面的單字是所有跟種子單字清單有關係的變化形及原型.
例如種子單字清單裡有：benefit 然後在文章內使用了benefiting那麼返回的vocabulary array裡面就給我benefiting
例如種子單字清單裡有：Achievement然後在文章內使用了Achievement和Achievements那麼返回的vocabulary array裡面就給我Achievements, Achievement 這兩個
"""
}


// 定義主結構
struct StoryDataModel: Codable {
    let title: Title
    let story: [StoryItem]
    let vocabulary: [String]
    
    // 定義 StoryItem 結構
    struct StoryItem: Codable {
        let article: String
        let translate: String
    }
    
    struct Title: Codable {
        let en: String
        let ch: String
    }
}

extension StoryDataModel {
    static var mock: StoryDataModel {
        return try! JSONDecoder().decode(StoryDataModel.self, from: mockData.data(using: .utf8)!)
    }
}

extension StoryDataModel.StoryItem {
//    func mark
}

private extension StoryDataModel {
    static var mockData: String {
"""
        {
          "title" : {
            "en" : "The Path to Effective Development",
            "ch" : "有效發展之道"
          },
          "story" : [
            {
              "article" : "In a large corporation, planning for an upcoming conference required extensive effort and coordination among the team.",
              "translate" : "在一家大型公司中，對即將到來的會議進行策劃需要團隊間的廣泛努力和協調。"
            },
            {
              "article" : "The supervisor outlined the responsibilities of each candidate, emphasizing the importance of training and effective communication.",
              "translate" : "主管概述了每位候選人的責任，並強調了培訓和有效溝通的重要性。"
            },
            {
              "article" : "During the conference, a presentation on operation improvement strategies highlighted the benefits of proper evaluation and implementation.",
              "translate" : "在會議期間，關於運營改進策略的演示突出了正確評估和實施的好處。"
            },
            {
              "article" : "After discussions and consultation, the team agreed to enter a contract that would facilitate ongoing development and education.",
              "translate" : "經過討論和諮詢，團隊決定簽訂一份合同，以促進持續的發展和教育。"
            }
          ],
          "vocabulary" : [
            "effort",
            "planning",
            "supervisor",
            "candidate",
            "training",
            "communication",
            "presentation",
            "operation",
            "evaluation",
            "improvement",
            "benefit",
            "development",
            "consultation",
            "contract",
            "education"
          ]
        }
"""
    }
}
