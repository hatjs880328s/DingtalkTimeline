//
//  *******************************************
//  
//  ViewController.swift
//  TimeLine
//
//  Created by Noah_Shan on 2019/8/15.
//  Copyright © 2018 Inpur. All rights reserved.
//  
//  *******************************************
//


import UIKit

class ViewController: UIViewController {

    let timeLine = TimelineProgress()

    override func viewDidLoad() {
        super.viewDidLoad()

        timeLine.lifeCircleProgress()

        print("gos")

        let allframes = timeLine.progressEachFrame()

        for eachItem in allframes {
            print(eachItem)
            let vi = UIView()
            vi.layer.borderColor = UIColor.black.cgColor
            vi.layer.borderWidth = 1
            vi.layer.cornerRadius = 5
            vi.layer.masksToBounds = true
            vi.frame = eachItem
            self.view.addSubview(vi)
            vi.backgroundColor = UIColor.yellow
        }
    }


}

