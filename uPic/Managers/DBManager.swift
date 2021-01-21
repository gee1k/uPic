//
//  DBManager.swift
//  uPic
//
//  Created by Svend Jin on 2019/12/24.
//  Copyright © 2019 Svend Jin. All rights reserved.
//

import Foundation
import WCDBSwift

public class DBManager {
    
    // static
    public static var shared = DBManager()
    
    private var database: Database!
    
    init() {
        Database.globalTrace(ofError: { (error) in
           switch error.type {
           case .sqliteGlobal:break
           case .warning:
               print("[WCDB][WARNING] \(error.description)")
           default:
               print("[WCDB][ERROR] \(error.description)")
           }
        })
        debugPrintOnly("数据库地址：\(Constants.CachePath.databasePath)")
        database = Database(withPath: Constants.CachePath.databasePath)
        createHistoryTable()
        createOutputFormatTable()
    }
    
    deinit {
        close()
    }
    
    func close() {
        database.close()
    }
}

extension DBManager {
    private func createHistoryTable() {
        do {
            try database.create(table: Constants.CachePath.historyTableName, of: HistoryThumbnailModel.self)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func insertHistory(_ model: HistoryThumbnailModel) {
        do {
            try database.insert(objects: model, intoTable: Constants.CachePath.historyTableName)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func insertHistorys(_ models: [HistoryThumbnailModel]) {
        do {
            try database.insert(objects: models, intoTable: Constants.CachePath.historyTableName)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func getHistoryList() -> [HistoryThumbnailModel] {
        var list: [HistoryThumbnailModel] = []
        do {
            list = try database.getObjects(on: HistoryThumbnailModel.Properties.all, fromTable: Constants.CachePath.historyTableName, orderBy: [HistoryThumbnailModel.Properties.identifier.asOrder(by: .descending)])
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
        return list
    }
    
    func clearHistory() {
        try? database.delete(fromTable: Constants.CachePath.historyTableName)
    }
    
    func deleteHositoryFirst(_ k: Int = 1) {
        try? database.delete(fromTable: Constants.CachePath.historyTableName, where: nil, orderBy: [HistoryThumbnailModel.Properties.identifier.asOrder(by: .ascending)], limit: k)
    }
}

// MARK: OutputFormat
extension DBManager {
    private func createOutputFormatTable() {
        do {
            try database.create(table: Constants.CachePath.outputFormatTableTableName, of: OutputFormatModel.self)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func insertOutputFormat(_ model: OutputFormatModel) {
        do {
            try database.insert(objects: model, intoTable: Constants.CachePath.outputFormatTableTableName)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func saveOutputFormats(_ models: [OutputFormatModel]) {
        do {
            try database.delete(fromTable: Constants.CachePath.outputFormatTableTableName)
            try database.insert(objects: models, intoTable: Constants.CachePath.outputFormatTableTableName)
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
    }
    
    func getOutputFormatList() -> [OutputFormatModel] {
        var list: [OutputFormatModel] = []
        do {
            list = try database.getObjects(on: OutputFormatModel.Properties.all, fromTable: Constants.CachePath.outputFormatTableTableName, orderBy: [OutputFormatModel.Properties.identifier.asOrder(by: .ascending)])
            
            // 检查是否存在输出格式数据
            if (list.count == 0) {
                list = OutputFormatModel.getDefaultOutputFormats()
                saveOutputFormats(list)
            }
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
        return list
    }
    
    func getOutputFormat(_ identifier: Int) -> OutputFormatModel? {
        return try? database.getObject(on: OutputFormatModel.Properties.all, fromTable: Constants.CachePath.outputFormatTableTableName, where: OutputFormatModel.Properties.identifier == identifier)
    }
    
    func deleteOutputFormat(_ identifier: Int) {
        try? database.delete(fromTable: Constants.CachePath.outputFormatTableTableName,
                             where: OutputFormatModel.Properties.identifier == identifier,
                             orderBy: [OutputFormatModel.Properties.identifier.asOrder(by: .ascending)]
        )
    }
}
