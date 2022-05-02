//
//  ViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/13.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift
import SQLite

struct User: Codable {
    let name: String?
    let id: Int64
    let email: String
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    var coor: Coordinator<UIViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sql()
    }
    
    // api 測試
    private func demoRequest() {
        typealias Req = AzureDictionary
        let request = Req(queryModel: .init(Text: "immortal"))
        let api = RequestBuilder<Req>()
        api.send(req: request)
        api.result.subscribe(onNext: { res in
            guard let res = res else { return }
            print(res)
        }).disposed(by: disposeBag)
    }
    
    // 相機畫面
    private func testCapture() {
        coor = CaptureVocabularyCoordinator(rootViewController: self)
        coor.start()
    }
    
    // popup 頁面
    private func testPopupPage() {
        coor = CreateVocabularyCoordinator(rootViewController: self, vocabulary: "immortal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.coor.start()
        }
    }
    
    // SQLite
    private func sql() {
//        AzureDictionaryORM().createTable()
//        AzureDictionaryORM().clear()
//        AzureDictionaryTranslationORM().createTable()
//        AzureDictionaryTranslationORM().clear()
        
//        let demoModels = try! JSONDecoder().decode([AzureDictionaryModel].self, from: testDate!)
//        demoModels.first?.save()
        
//        let query = AzureDictionaryORM.table
//            .filter(AzureDictionaryORM.normalizedSource == "immortal".normalized)
//        let d = AzureDictionaryORM.prepare(query)
//        print(d)
        
        let q = AzureDictionaryModel.load(key: "immortal")
        print(q)
        
//        AzureDictionaryORM.drop()
//        AzureDictionaryTranslationORM.drop()
    }
}

// MARK: -
let testDate = """
[
  {
    "normalizedSource" : "immortal",
    "translations" : [
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 397,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 140,
            "numExamples" : 5,
            "displayText" : "immortality",
            "normalizedText" : "immortality"
          },
          {
            "frequencyCount" : 33,
            "numExamples" : 5,
            "displayText" : "monumental",
            "normalizedText" : "monumental"
          },
          {
            "frequencyCount" : 32,
            "numExamples" : 5,
            "displayText" : "enduring",
            "normalizedText" : "enduring"
          },
          {
            "frequencyCount" : 26,
            "numExamples" : 10,
            "displayText" : "eternal",
            "normalizedText" : "eternal"
          },
          {
            "frequencyCount" : 20,
            "numExamples" : 5,
            "displayText" : "undying",
            "normalizedText" : "undying"
          },
          {
            "frequencyCount" : 12,
            "numExamples" : 5,
            "displayText" : "imperishable",
            "normalizedText" : "imperishable"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "不朽",
        "confidence" : 0.37730000000000002,
        "normalizedTarget" : "不朽"
      },
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 36,
            "numExamples" : 5,
            "displayText" : "fairy",
            "normalizedText" : "fairy"
          },
          {
            "frequencyCount" : 34,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 12,
            "numExamples" : 3,
            "displayText" : "immortals",
            "normalizedText" : "immortals"
          },
          {
            "frequencyCount" : 4,
            "numExamples" : 1,
            "displayText" : "Xianren",
            "normalizedText" : "xianren"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "仙人",
        "confidence" : 0.13950000000000001,
        "normalizedTarget" : "仙人"
      },
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 84,
            "numExamples" : 15,
            "displayText" : "fairy",
            "normalizedText" : "fairy"
          },
          {
            "frequencyCount" : 41,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 31,
            "numExamples" : 15,
            "displayText" : "gods",
            "normalizedText" : "gods"
          },
          {
            "frequencyCount" : 24,
            "numExamples" : 5,
            "displayText" : "immortals",
            "normalizedText" : "immortals"
          },
          {
            "frequencyCount" : 12,
            "numExamples" : 5,
            "displayText" : "deity",
            "normalizedText" : "deity"
          },
          {
            "frequencyCount" : 4,
            "numExamples" : 2,
            "displayText" : "genie",
            "normalizedText" : "genie"
          },
          {
            "frequencyCount" : 3,
            "numExamples" : 5,
            "displayText" : "celestial",
            "normalizedText" : "celestial"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "神仙",
        "confidence" : 0.12559999999999999,
        "normalizedTarget" : "神仙"
      },
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 213,
            "numExamples" : 5,
            "displayText" : "eternal life",
            "normalizedText" : "eternal life"
          },
          {
            "frequencyCount" : 120,
            "numExamples" : 5,
            "displayText" : "live forever",
            "normalizedText" : "live forever"
          },
          {
            "frequencyCount" : 76,
            "numExamples" : 5,
            "displayText" : "immortality",
            "normalizedText" : "immortality"
          },
          {
            "frequencyCount" : 47,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 24,
            "numExamples" : 14,
            "displayText" : "eternal",
            "normalizedText" : "eternal"
          },
          {
            "frequencyCount" : 15,
            "numExamples" : 4,
            "displayText" : "immortalized",
            "normalizedText" : "immortalized"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "永生",
        "confidence" : 0.1104,
        "normalizedTarget" : "永生"
      },
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 11,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 4,
            "numExamples" : 2,
            "displayText" : "lasts forever",
            "normalizedText" : "lasts forever"
          },
          {
            "frequencyCount" : 3,
            "numExamples" : 1,
            "displayText" : "immortality",
            "normalizedText" : "immortality"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "永垂不朽",
        "confidence" : 0.1062,
        "normalizedTarget" : "永垂不朽"
      },
      {
        "posTag" : "ADJ",
        "backTranslations" : [
          {
            "frequencyCount" : 73,
            "numExamples" : 5,
            "displayText" : "live forever",
            "normalizedText" : "live forever"
          },
          {
            "frequencyCount" : 13,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 10,
            "numExamples" : 5,
            "displayText" : "immortality",
            "normalizedText" : "immortality"
          },
          {
            "frequencyCount" : 4,
            "numExamples" : 1,
            "displayText" : "longevity",
            "normalizedText" : "longevity"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "长生不老",
        "confidence" : 0.077200000000000005,
        "normalizedTarget" : "长生不老"
      },
      {
        "posTag" : "NOUN",
        "backTranslations" : [
          {
            "frequencyCount" : 388,
            "numExamples" : 0,
            "displayText" : "Xian",
            "normalizedText" : "xian"
          },
          {
            "frequencyCount" : 154,
            "numExamples" : 15,
            "displayText" : "fairy",
            "normalizedText" : "fairy"
          },
          {
            "frequencyCount" : 68,
            "numExamples" : 15,
            "displayText" : "cents",
            "normalizedText" : "cents"
          },
          {
            "frequencyCount" : 40,
            "numExamples" : 6,
            "displayText" : "sin",
            "normalizedText" : "sin"
          },
          {
            "frequencyCount" : 26,
            "numExamples" : 5,
            "displayText" : "immortal",
            "normalizedText" : "immortal"
          },
          {
            "frequencyCount" : 14,
            "numExamples" : 0,
            "displayText" : "paradise",
            "normalizedText" : "paradise"
          },
          {
            "frequencyCount" : 5,
            "numExamples" : 0,
            "displayText" : "Shania",
            "normalizedText" : "shania"
          }
        ],
        "prefixWord" : "",
        "displayTarget" : "仙",
        "confidence" : 0.063799999999999996,
        "normalizedTarget" : "仙"
      }
    ],
    "displaySource" : "immortal"
  }
]
""".data(using: .utf8)










