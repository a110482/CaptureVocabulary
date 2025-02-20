//
//  Decision.swift
//  jx_sbk
//
//  Created by Elijah on 2021/7/13.
//

import Foundation
import Moya

public enum DecisionAction<R: Request> {
    case continueWith(Moya.Response)
    case restartWith(decisions: [Decision])
    case errored(error: Error)
    case done(value: R.ResponseModel)
}

public protocol Decision {
    func shouldApply<Req: Request>(request: Req, response: Moya.Response) -> Bool
    func apply<Req: Request>(
        request: Req,
        response: Moya.Response,
        done closure: @escaping (DecisionAction<Req>) -> Void)
}


