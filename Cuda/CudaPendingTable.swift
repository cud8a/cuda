//
//  CudaPendingTable.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

class CudaPendingTable: CudaDatabase
{
    let tableName = "pending"
    
    func add(pending: CudaPendingRow) -> CudaDatabaseResult
    {
        var result = CudaDatabaseResult.Error
        
        if let database = getDatabase()
        {
            var columns = "method,url,data"
            
            let data = pending.data.stringByReplacingOccurrencesOfString("'", withString: "''")
            
            var values = "'\(pending.method)','\(pending.url)','\(data)'"
            
            if let contentType = pending.contentType
            {
                columns += ",content_type"
                values += ",'\(contentType)'"
            }
            
            if let extra = pending.extra
            {
                columns += ",extra"
                values += ",'\(extra)'"
            }
            
            if !database.executeUpdate("insert into \(tableName) (\(columns)) values (\(values))", withArgumentsInArray: [])
            {
                print("PendingTable: insert failed: \(database.lastErrorMessage())")
            }
            else
            {
                pending.id = Int(database.lastInsertRowId())
                result = .Inserted
            }
            
            database.close()
        }
        
        return result
    }
    
    func nextForLookup(lastId lastId: Int) -> CudaPendingRow?
    {
        if let database = getDatabase()
        {
            var pending: CudaPendingRow?
            
            if let rs = database.executeQuery("select * from \(tableName) where retries < 10 and id > \(lastId) limit 1", withArgumentsInArray: [])
            {
                while rs.next()
                {
                    pending = CudaPendingRow(id: Int(rs.intForColumn("id")), url: rs.stringForColumn("url"), method: rs.stringForColumn("method"), data: rs.stringForColumn("data"), contentType: rs.stringForColumn("content_type"), status: CudaPendingStatus(rawValue: Int(rs.intForColumn("status"))), retries: Int(rs.intForColumn("retries")), dateLastTry: rs.dateForColumn("date_last_try"), extra: rs.stringForColumn("extra"))
                }
            }
            else
            {
                print("PendingTable: select failed: \(database.lastErrorMessage())")
            }
            
            database.close()
            
            return pending
        }
        
        return nil
    }
    
    func update(pending: CudaPendingRow) -> CudaDatabaseResult
    {
        var result = CudaDatabaseResult.Error
        
        if let database = getDatabase(), id = pending.id
        {
            var values = "status=\(pending.status),retries=\(pending.retries)"
            
            if pending.extra != nil
            {
                values += ",extra='\(pending.extra!)'"
            }
            
            if pending.dateLastTry != nil
            {
                values += ",date_last_try='\(database.stringFromDate(pending.dateLastTry!))'"
            }
            
            if !database.executeUpdate("update \(tableName) set \(values) where id=\(id)", withArgumentsInArray: [])
            {
                print("PendingTable: update failed: \(database.lastErrorMessage())")
            }
            else
            {
                result = .Updated
            }
            
            database.close()
        }
        
        return result
    }
    
    func delete(pending: CudaPendingRow) -> CudaDatabaseResult
    {
        var result = CudaDatabaseResult.Error
        
        if let database = getDatabase(), id = pending.id
        {
            if !database.executeUpdate("delete from \(tableName) where id=\(id)", withArgumentsInArray: [])
            {
                print("PendingTable: delete failed: \(database.lastErrorMessage())")
            }
            else
            {
                result = .Deleted
            }
            
            database.close()
        }
        
        return result
    }
}
