//
//  MyRequest.swift
//  Cuda
//
//  Created by Tamas Bara on 26.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation
import UIKit

class MyRequest: CudaRequest
{
    let txtView: UITextView
    
    init(url: String, txtView: UITextView)
    {
        self.txtView = txtView
        super.init(url: url, logEnabled: true)
    }
    
    override func requestOk(response: NSURLResponse, data: NSData)
    {
        super.requestOk(response, data: data)
        
        Cuda.executeOnMainThread()
        {
            self.txtView.text = "\(NSString(data: data, encoding: NSUTF8StringEncoding))"
        }
    }
    
    override func requestError(error: NSError)
    {
        super.requestError(error)
    }
}
