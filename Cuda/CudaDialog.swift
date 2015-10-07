//
//  CudaDialog.swift
//  Cuda
//
//  Created by Tamas Bara on 25.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import UIKit

class CudaDialog: UIViewController
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLeft: CudaRoundButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnRight: CudaRoundButton!
    @IBOutlet var dialog: UIView!
    @IBOutlet weak var txtInput: UITextField!
    
    var dialogTitle: String?
    var dialogMessage: String?
    var leftBtnTitle: String?
    var rightBtnTitle: String?
    var inputText: String?
    
    var leftBtnClicked: (() -> ())?
    var rightBtnClicked: (() -> ())?
    
    init()
    {
        super.init(nibName: "CudaDialog", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let bounds = UIScreen.mainScreen().bounds
        
        view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        view.alpha = 0
        
        let x = (bounds.width - dialog.frame.width) / 2
        let y = (bounds.height - dialog.frame.height) / 2
        dialog.frame.offsetInPlace(dx: x, dy: y)
        dialog.layer.cornerRadius = 6
        dialog.layer.masksToBounds = true
        dialog.alpha = 0
        
        if inputText != nil
        {
            txtInput.text = inputText
        }
        
        if dialogTitle != nil
        {
            lblTitle.text = dialogTitle
        }
        
        if dialogMessage != nil
        {
            lblMessage.text = dialogMessage
        }
        
        if leftBtnTitle != nil
        {
            btnLeft.setTitle(leftBtnTitle, forState: UIControlState.Normal)
        }
        
        if rightBtnTitle != nil
        {
            btnRight.setTitle(rightBtnTitle, forState: UIControlState.Normal)
        }
    }
    
    func showDialog(parentViewController: UIViewController)
    {
        parentViewController.view.addSubview(view)
        parentViewController.view.addSubview(dialog)
    }
    
    func hideDialog()
    {
        UIView.animateWithDuration(0.2, animations:
        {
            self.dialog.alpha = 0.0
            self.view.alpha = 0.0
        },
        completion:
        { finished in
            self.dialog.removeFromSuperview()
            self.view.removeFromSuperview()
        })
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.2, animations:
        {
            self.dialog.alpha = 1.0
            self.view.alpha = 1.0
        })
    }
    
    @IBAction func btnLeftClicked(sender: AnyObject)
    {
        leftBtnClicked?()
    }
    
    @IBAction func btnRightClicked(sender: AnyObject)
    {
        rightBtnClicked?()
    }
}
