//
//  RxOutput.swift
//  CaptureVocabulary
//
//  Created by ElijahTan on 2024/9/5.
//

import Foundation

/// 用來隔離 rx publish relay 的訊號
/// e.x
/// class Foo {
///     private let event = PublishRelay<Void>()
///     lazy var output = Output(self)
/// }
///
/// extension Foo  {
///     class Output: RxOutput<Foo> {
///         lazy var event = target.event.asObservable()
///     }
/// }
///
/// now you can use `foo.output.event` to subscribe the event
class RxOutput<T: AnyObject> {
    weak var target: T!
    
    init(_ target: T) {
        self.target = target
    }
}
