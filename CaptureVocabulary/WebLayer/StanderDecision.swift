//
//  StanderDecision.swift
//  jx_sbk
//
//  Created by Elijah on 2021/7/15.
//

import Foundation
import Moya

struct StanderDecision: Decision {
    func shouldApply<Req>(request: Req, response: Response) -> Bool where Req : Request {
        return true
    }
    
    func apply<Req>(request: Req, response: Response, done closure: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        let resData = response.data
        do {
            let model = try JSONDecoder().decode(Req.ResponseModel.self, from: resData)
            closure(.done(value: model))
        }
        catch {
            #if DEBUG
            let _ = try! JSONDecoder().decode(Req.ResponseModel.self, from: resData)
            #endif
        }
    }
}


