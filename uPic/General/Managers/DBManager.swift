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
        database = Database(withPath: Constants.CachePath.databasePath)
        createHistoryTable()
    }
    
    deinit {
        database.close()
    }
}

extension DBManager {
    private func createHistoryTable() {
        try? database.create(table: Constants.CachePath.historyTableName, of: HistoryThumbnailModel.self)
    }
    
    func insertHistory(_ model: HistoryThumbnailModel) {
        try? database.insert(objects: model, intoTable: Constants.CachePath.historyTableName)
    }
    
    func insertHistorys(_ models: [HistoryThumbnailModel]) {
        try? database.insert(objects: models, intoTable: Constants.CachePath.historyTableName)
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
