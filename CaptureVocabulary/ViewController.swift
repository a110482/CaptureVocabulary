//
//  ViewController.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/13.
//

import UIKit
import SnapKit
import SwifterSwift
import VisionKit
import Vision


class ViewController: UIViewController {
    let cap = CaptureViewController()
    let capContainerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(capContainerView)
        capContainerView.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(20)
            $0.height.equalTo(300)
        }
        
        addChildViewController(cap, toContainerView: capContainerView)
        cap.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

