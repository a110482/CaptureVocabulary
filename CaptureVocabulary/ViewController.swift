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


class ViewController: UIViewController {
    var createVocabularyCoordinator: CreateVocabularyCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        demoRequest()
//        createVocabularyCoordinator = CreateVocabularyCoordinator(rootViewController: self)
//        createVocabularyCoordinator.start()
    }
}

private func demoRequest() {
    typealias Req = AzureTranslate
    let request = Req(text: "Hello")
    let api = RequestBuilder<Req>()
    api.send(req: request)
}




struct KeyPlistModel: Codable {
    let azureKey: String?
}


struct PlistReader {
    static func read<Model: Codable>(fileName: String, modelType: Model.Type) -> Model? {
        guard let keyPlistPath = Bundle.main.path(
            forResource: "key", ofType: "plist") else {
            return nil
        }
        guard let data = try? Data(
            contentsOf:URL(fileURLWithPath: keyPlistPath)) else { return nil }
        return try? PropertyListDecoder().decode(Model.self, from: data)
    }
}
