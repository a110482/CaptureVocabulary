//
//  OBRequestBuilder.swift
//  OB_API
//
//  Created by 譚培成 on 2021/10/22.
//

import Foundation
import Alamofire
import Foundation
import RxSwift
import Moya

public class RequestBuilder<Req: Request> {
    public var result: Observable<Req.ResponseModel?> { _result.asObserver().skip(1) }
    public var err: Observable<Error?> { _err.asObserver().skip(1) }
    
    public init() {}
    public func send(req: Req) {
        let plugins = configPlugins(req)
        MoyaProvider<Req>(session: DefaultAlamofireManager.shared, plugins: plugins).send(
            request: req
        ){
            switch $0 {
            case .failure(let err):
                self._err.onNext(err)
            case .success(let model):
                self._result.onNext(model)
            }
        }
    }
    
    private let _result = BehaviorSubject<Req.ResponseModel?>(value: nil)
    private let _err = BehaviorSubject<Error?>(value: nil)
    private func configPlugins(_ req: Req) -> Array<PluginType> {
        var plugins: Array<PluginType> = []
        #if block//DEBUG
        plugins.append(configLogger())
        #endif
        return plugins
    }
}

// MARK: - Logger
private extension RequestBuilder {
    func configLogger() -> NetworkLoggerPlugin {
        let logOptions: NetworkLoggerPlugin.Configuration.LogOptions = .verbose
        
        let formatter = NetworkLoggerPlugin.Configuration.Formatter(entry: { identifier, message, target -> String in
            func line(_ title: String) -> String {
                "\n\n================ \(title) ================\n\n"
            }
            
            // start line
            var startLine = ""
            if identifier == "Request" {
                startLine = line("Request Start: \(type(of: target))")
            } else if identifier == "Response" {
                startLine = line("Response Start: \(type(of: target))")
            }
            
            // end line
            var endLine = ""
            if identifier == "HTTP Request Method" {
                endLine = line("Request End: \(type(of: target))")
            } else if identifier == "Response Body" {
                endLine = line("Response End: \(type(of: target))")
            }
            
            // message
            var message = message
            if identifier == "Response Body" || identifier == "Request Body"{
                let data = message.data(using: .utf8)!
                message = data.prettyPrintedJSONString()
            }
            
            let date = Date()
            let msg = "SBK_Logger: [\(date)] \(identifier): \(message)"
            
            return startLine + msg + endLine
        })
        
        let conf = NetworkLoggerPlugin.Configuration(
            formatter: formatter,
            logOptions: logOptions
        )
        return NetworkLoggerPlugin(configuration: conf)
    }
    
}

// extension
internal extension Data {
    func prettyPrintedJSONString() -> String {
        guard
            let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to read JSON Object.")
                return ""
        }
        return prettyJSONString
    }
}


class DefaultAlamofireManager: Alamofire.Session {
    static let shared: Alamofire.Session = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 10 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 10 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return Alamofire.Session(configuration: configuration)
    }()
}

// MARK: - Demo
private func demoRequest() {
//    typealias Req = AzureTranslate
//    let request = Req(userName: "elijah")
//    let api = OBRequestBuilder<Req>()
//    api.send(req: request)
}
