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
    }


}

