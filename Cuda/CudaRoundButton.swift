//
//  CudaRoundButton.swift
//  Cuda
//
//  Created by Tamas Bara on 25.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import UIKit

class CudaRoundButton: UIButton
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 5;
    }
}
