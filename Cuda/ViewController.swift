//
//  ViewController.swift
//  Cuda
//
//  Created by Tamas Bara on 25.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var cudaDialog: CudaDialog?
    
    let fetchControl = CudaFetchControl(key: "CudaFC", timespan: 3)
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtView: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let icon = CudaIconCache.sharedInstance.getIcon("http://41.media.tumblr.com/294b3220194dd30033e1561130092b16/tumblr_n3h407Kg1L1trb5guo1_1280.jpg", size: CGSize(width: 174, height: 174), imgView: imgView)
        {
            imgView.image = icon
        }
        
        if fetchControl.shouldFetch()
        {
            let pending = CudaPendingRow(url: "http://posttestserver.com/post.php", method: "POST", data: "{\"hallo\": \"welt\"}", contentType: "application/json; charset=utf-8")
            CudaPostsQueue.singleton.addToQueue(pending)
            fetchControl.stamp()
        }
    }
    
    @IBAction func showDialogClicked(sender: AnyObject)
    {
        cudaDialog = CudaDialog()
        cudaDialog!.dialogTitle = "Cuda"
        cudaDialog!.dialogMessage = "This is a Cuda Dialog"
        cudaDialog!.leftBtnTitle = "No"
        cudaDialog!.rightBtnTitle = "Yes"
        cudaDialog!.leftBtnClicked = noClicked
        cudaDialog!.rightBtnClicked = yesClicked
        cudaDialog!.inputText = "http://posttestserver.com"
        cudaDialog!.showDialog(self)
    }
    
    func yesClicked()
    {
        cudaDialog!.hideDialog()
        
        if let text = cudaDialog!.txtInput.text
        {
            let myRequest = MyRequest(url: text, txtView: txtView)
            myRequest.sendAndReceive()
        }
    }
    
    func noClicked()
    {
        cudaDialog!.hideDialog()
    }
}
