//
//  Request.swift
//  jx_sbk
//
//  Created by Elijah on 2021/7/13.
//

import Foundation
import Moya

public protocol Request: TargetType {
    associatedtype ResponseModel: Decodable
    var parameters: [String: Any] { get }
    var decisions: [Decision] { get }
}

 
