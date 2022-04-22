//
//  HeaderStorage.swift
//  CaptureVocabulary
//
//  Created by 譚培成 on 2022/4/23.
//

import Foundation


public class HeaderStorage {
    public struct Setting {
        /// head key in this array, will be share to all host
        /// e.x. "ssoToken"
        public var shareHeaderKeys: [String] = []
    }
    
    static let `default` = HeaderStorage()
    
    var setting = Setting()
    
    public init() {}

    public func setHeader(for url: URL, key: String, value: String) {
        guard let host = getHost(url: url) else { return }
        #warning("Todo")
        // 處理 shareHeaderKeys
        if let index = headerStorages.firstIndex( where: { $0.host == host } ) {
            var newStorage = headerStorages[index]
            newStorage.headerKeyValue[key] = value
            headerStorages[index] = newStorage
        } else {
            let newStorage = Storage(host: host, headerKeyValue: [key: value])
            headerStorages.append(newStorage)
        }
    }

    public func getHeader(for url: URL, key: String) -> String? {
        guard let host = getHost(url: url) else { return nil }
        if let index = headerStorages.firstIndex( where: { $0.host == host } ) {
            return headerStorages[index].headerKeyValue[key]
        }
        return nil
    }
    
    public func getAllHeaders(for url: URL) -> [String: String] {
        guard let host = getHost(url: url) else { return [:] }
        guard let index = headerStorages.firstIndex( where: { $0.host == host } ) else { return [:] }
        return headerStorages[index].headerKeyValue
    }
    
    private func getHost(url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        return components.host
    }

    private struct Storage: Hashable {
        let host: String
        var headerKeyValue: Dictionary<String, String> = [:]
    }

    private var headerStorages: Array<Storage> = []
}

