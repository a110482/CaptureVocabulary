//
//  MoyaProvider+Ext.swift
//  jx_sbk
//
//  Created by Elijah on 2021/7/15.
//

import Foundation
import Moya


extension MoyaProvider where Target: Request {
    typealias Handler = Result<Target.ResponseModel, Error>
    
    func send(
        request: Target,
        decisions: [Decision]? = nil,
        handler: @escaping (Handler) -> Void
    ) {
        self.request(request) {
            result in
            switch result {
            case .success(let response):
                self.handleDecision(
                    request,
                    response: response,
                    decisions: decisions ?? request.decisions,
                    handler: handler
                )
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
//    func send(
//        request: Target,
//        decisions: [Decision]? = nil
//    ) async -> Handler {
//        
//    }
    
    
    
    private func handleDecision(
        _ request: Target,
        response: Moya.Response,
        decisions: [Decision]
    ) async -> Handler? {
        guard !decisions.isEmpty else {
            assert(false, "No decision left but did not reach a stop.")
            return nil
        }
        var decisions = decisions
        let current = decisions.removeFirst()
        
        guard current.shouldApply(
            request: request,
            response: response
        ) else {
            return await handleDecision(
                request,
                response: response,
                decisions: decisions
            )
        }
        
        let action = await current.apply(request: request, response: response)
        
        switch action {
        case .continueWith(let response):
            return await self.handleDecision(
                request,
                response: response,
                decisions: decisions
            )
        case .restartWith(decisions: let decisions):
            //                self.send(
            //                    request: request,
            //                    decisions: decisions,
            //                    handler: handler
            //                )
            return nil
        case .errored(error: let error):
            return .failure(error)
        case .done(value: let value):
            return .success(value)
        }
    }

    private func handleDecision(
        _ request: Target,
        response: Moya.Response,
        decisions: [Decision],
        handler: @escaping (Handler) -> Void
    ) {
        guard !decisions.isEmpty else {
            assert(false, "No decision left but did not reach a stop.")
            return
        }

        var decisions = decisions
        let current = decisions.removeFirst()

        guard current.shouldApply(
            request: request,
            response: response
        ) else {
            handleDecision(
                request,
                response: response,
                decisions: decisions,
                handler: handler
            )
            return
        }
        
        current.apply(
            request: request,
            response: response
        ) {
            action in
            switch action {
            case .continueWith(let response):
                self.handleDecision(
                    request,
                    response: response,
                    decisions: decisions,
                    handler: handler
                )
            case .restartWith(decisions: let decisions):
                self.send(
                    request: request,
                    decisions: decisions,
                    handler: handler
                )
                break
            case .errored(error: let error):
                handler(.failure(error))
            case .done(value: let value):
                handler(.success(value))
            }
        }
    }
}
