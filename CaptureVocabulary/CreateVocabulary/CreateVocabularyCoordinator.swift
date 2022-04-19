//
//  CreateVocabularyCoordinator.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/18.
//

import UIKit
import SnapKit
import SwifterSwift
import Vision
import RxCocoa
import RxSwift
import Then

// MARK: - Coordinator
class CreateVocabularyCoordinator: Coordinator<UIViewController> {
    var viewController: CreateVocabularyViewController!
    var viewModel: CreateVocabularyViewModel!
    
    override func start() {
        guard !started else { return }
        super.start()
        viewController = CreateVocabularyViewController()
        viewModel = CreateVocabularyViewModel()
        viewController.bind(viewModel: viewModel)
        present(viewController: viewController)
    }
}

// MARK: - VM
class CreateVocabularyViewModel {
    struct Output {
        let identifyWords = BehaviorRelay<[String]>(value: [])
    }
    let output = Output()
    
    func handleObservations(_ observations: [VNRecognizedTextObservation]) {
        guard observations.count > 0 else { return }
        let words = refineObservations(observations)
        DispatchQueue.main.async {
            self.output.identifyWords.accept(words)
        }
    }
    
}

private extension CreateVocabularyViewModel {
    func refineObservations(_ observations: [VNRecognizedTextObservation]) -> [String] {
        // 改由圖片位置靠近中央處優先
        var refinedAlternateWords: [(word: String, distance: CGFloat)] = []
        
        for lineObservation in observations {
            if refinedAlternateWords.count >= 5 {
                return refinedAlternateWords.map { $0.word }
            }
            guard let textLine = lineObservation.topCandidates(1).first else { continue }
            let words = textLine.string.split{ $0.isWhitespace }.map{ String($0)}
            for word in words {
                guard word.count > 2 else { continue }
                if let wordRange = textLine.string.range(of: word),
                   let wordRect = try? textLine.boundingBox(for: wordRange)?.boundingBox{
                    // 座標是位置的百分比, 原點是左下角, 所以最接近中心點的就是 (0.5, 0.5)
                    let absoluteCenter = CGPoint(x: 0.5, y: 0.5)
                    let distance = absoluteCenter.distance(from: wordRect.center)
                    refinedAlternateWords.append((word: word, distance: distance))
                    refinedAlternateWords.sort(by: { $0.distance < $1.distance })
                    refinedAlternateWords = Array(refinedAlternateWords.prefix(5))
                }
            }
        }

//        words = words.sortedFromMiddle()
        return refinedAlternateWords.map { $0.0 }
    }
}

// MARK: - VC
class CreateVocabularyViewController: UIViewController {
    let captureViewController = CaptureViewController()
    let capContainerView = UIView()
    let tableView = UITableView().then {
        $0.register(cellWithClass: UITableViewCell.self)
    }
    var cellModels: [String] = []
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func bind(viewModel: CreateVocabularyViewModel) {
        captureViewController.action.subscribe(onNext: { [weak viewModel] act in
            switch act {
            case .identifyText(let observations):
                viewModel?.handleObservations(observations)
            }
        }).disposed(by: disposeBag)
        
        viewModel.output.identifyWords.subscribe(onNext: { [weak self] cellModels in
            guard let self = self else { return }
            self.cellModels = cellModels
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
}

// UI
extension CreateVocabularyViewController {
    func configUI() {
        addCaptureViewController()
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(capContainerView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func addCaptureViewController() {
        view.addSubview(capContainerView)
        capContainerView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(captureViewController, toContainerView: capContainerView)
        captureViewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        
    }
}


extension CreateVocabularyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        cell.textLabel?.text = cellModels[indexPath.row]
        return cell
    }
    
    
}
