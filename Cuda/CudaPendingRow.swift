//
//  CudaPendingRow.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

enum CudaPendingStatus: Int, CustomStringConvertible
{
    case New = 0
    case Error = 1
    
    var description: String
    {
        return "\(self.rawValue)"
    }
}

class CudaPendingRow
{
    var id: Int?
    let url: String!
    let method: String!
    let data: String!
    var contentType: String?
    var status = CudaPendingStatus.New
    var retries = 0
    var dateLastTry: NSDate?
    var extra: String?
    
    init(id: Int?, url: String!, method: String!, data: String!, contentType: String?, status: CudaPendingStatus!, retries: Int!, dateLastTry: NSDate?, extra: String?)
    {
        self.id = id
        self.url = url
        self.method = method
        self.data = data
        self.contentType = contentType
        self.status = status
        self.retries = retries
        self.dateLastTry = dateLastTry
        self.extra = extra
    }
    
    init(url: String!, method: String!, data: String!, contentType: String?)
    {
        self.url = url
        self.method = method
        self.data = data
        self.contentType = contentType
    }
}
