//
//  *******************************************
//  
//  TimelineProgress.swift
//  TimeLine
//
//  Created by Noah_Shan on 2019/8/15.
//  Copyright © 2018 Inpur. All rights reserved.
//  
//  *******************************************
//


import UIKit
import IISwiftBaseUti

/*
 Feature:

 1.将每一个事件处理为一个对象，这个对象属性有： 开始时间 结束时间 自己层级 自己所在链表中item个数 debugnickname
 2.从第一级别开始查找：与“第一个”没有时间交集的都作为第一集别的事件

 3.从剩下的里面查找，与第一个没有时间交集的作为第二级别的事件
 4.遍历每一个第二级别的事件，找出与此事件有交集的第一级别事件，将有交集的事件作为当前事件的父节点存储起来，
    同时设置这些父节点的层级数为当前层级[这一步为递归操作]

 5.循环执行3、4步骤直到没有剩余的事件

 6.由于是引用类型，所有事件处理完毕，按照类中的层级、层级个数获取事件生成的view的frame
 */

class TimelineProgress: NSObject {

    /// 外部数据源数组
    var allItems: [OutLinkItemModel] = []

    /// 内部数据源数组
    var progressItems: [LinkItem]  = []

    /// 按层级拆分后的二维数组
    var lvGroups: [[LinkItem]] = []

    /// 最大宽度
    public let maxWidth: CGFloat = UIScreen.main.bounds.size.width

    /// 每一个小时的高度
    public let eachHeight: CGFloat = 48

    override init() {
        super.init()
        initData()
    }

    @objc public func lifeCircleProgress() {
        // 将外部数据源处理为内部数据源
        self.progressOutData2InnerData()
        // 处理items到二维数组中
        self.progressLvls()
        // 处理父子关系
        self.loopEachGroup()
        // 处理每一个节点的链表层级
        self.progressEachItemFathersLvl()
    }

    /// 测试做的外部数据源[开始时间排序处理得数据]
    func initData() {
        /// 2019 - 8 - 15  14：00 - 15：00
        let item1 = OutLinkItemModel()
        item1.startTime = Date(timeIntervalSince1970: 1565848800)
        item1.endTime = Date(timeIntervalSince1970: 1565852400)
        self.allItems.append(item1)
        /// 2019 - 8 - 15  14：30 - 19：30
        let item2 = OutLinkItemModel()
        item2.startTime = Date(timeIntervalSince1970: 1565850600)
        item2.endTime = Date(timeIntervalSince1970: 1565868600)
        self.allItems.append(item2)
        /// 2019 - 8 - 15  14：45 - 15：30
        let item3 = OutLinkItemModel()
        item3.startTime = Date(timeIntervalSince1970: 1565851500)
        item3.endTime = Date(timeIntervalSince1970: 1565854205)
        self.allItems.append(item3)
        /// 2019 - 8 - 15  15：30 - 16：00
        let item4 = OutLinkItemModel()
        item4.startTime = Date(timeIntervalSince1970: 1565854205)
        item4.endTime = Date(timeIntervalSince1970: 1565856000)
        self.allItems.append(item4)
        /// 2019 - 8 - 15  17：00 - 18：00
        let item5 = OutLinkItemModel()
        item5.startTime = Date(timeIntervalSince1970: 1565859600)
        item5.endTime = Date(timeIntervalSince1970: 1565863200)
        self.allItems.append(item5)
        /// 2019 - 8 - 15  17：30 - 18：00
        let item6 = OutLinkItemModel()
        item6.startTime = Date(timeIntervalSince1970: 1565861400)
        item6.endTime = Date(timeIntervalSince1970: 1565863200)
        self.allItems.append(item6)
        /// 2019 - 8 - 15  20：00 - 21：00
        let item7 = OutLinkItemModel()
        item7.startTime = Date(timeIntervalSince1970: 1565870400)
        item7.endTime = Date(timeIntervalSince1970: 1565874000)
        self.allItems.append(item7)
    }

    /// [1]将外部数据数组转为内部数据数组
    func progressOutData2InnerData() {
        for eachItem in self.allItems {
            let realItem = LinkItem(model: eachItem)
            self.progressItems.append(realItem)
        }
    }

    /// [2-1]循环处理所有事件，将之添加到对应数组中
    private func progressLvls() {
        var copyItemsArr = self.progressItems
        var lvl = 0
        while !copyItemsArr.isEmpty {
            let eachLvl = self.getEachLvlItems(lvl: lvl, arrs: copyItemsArr)
            self.lvGroups.append(eachLvl.result)
            // 将结果集从大数组中移除
            var revertIdx = eachLvl.resultIdx
            revertIdx.reverse()
            for eachIdx in 0 ..< revertIdx.count {
                copyItemsArr.remove(at: revertIdx[eachIdx])
            }
            lvl += 1
        }
    }

    /// [2-2]从某一个数组中获取某一级别的数据，并做引用存储
    private func getEachLvlItems(lvl: Int, arrs: [LinkItem]) -> (result: [LinkItem], resultIdx: [Int]) {
        if arrs.count == 0 { return ([], []) }
        var endTime = Date()
        var result = [LinkItem]()
        var resultIdx: [Int] = []
        for idx in 0 ..< arrs.count {
            if idx == 0 {
                result.append(arrs[idx])
                resultIdx.append(idx)
                endTime = arrs[idx].endTime
                arrs[idx].lvl = lvl
                continue
            }
            if arrs[idx].startTime >= endTime {
                result.append(arrs[idx])
                resultIdx.append(idx)
                endTime = arrs[idx].endTime
                arrs[idx].lvl = lvl
            }
        }
        return (result, resultIdx)
    }

    /// [3-1]循环处理二维数组中的每一个数组，处理父子关系
    private func loopEachGroup() {
        for eachItem in self.lvGroups {
            self.loopProgressEachLvItems(arrs: eachItem)
        }
    }

    /// [3-2]遍历某一个层级的所有item,找到所有它的父节点，添加到自己属性中
    /// 根据父亲节点处理父节点的孩子节点
    private func loopProgressEachLvItems(arrs: [LinkItem]) {
        guard let firstItem = arrs.first else { return }
        let currentIvl: Int = firstItem.lvl
        if currentIvl == 0 { return }
        let fatherLvl: Int = currentIvl - 1
        /// 所有上级事件
        let fatherGroup = self.lvGroups[fatherLvl]
        for eachItem in arrs {
            /// 从所有上级事件中寻找与自己有交集的item
            for eachFatherItem in fatherGroup {
                if !eachItem.calculate2AnotherItemHaveSameTime(anotherItem: eachFatherItem) { continue }
                eachItem.fatherItems.append(eachFatherItem)
                eachFatherItem.sonItems.append(eachItem)
            }
        }
    }

    /// [4]遍历每一个事件，处理此事件的父节点的层级
    private func progressEachItemFathersLvl() {
        for eachItem in self.progressItems {
            eachItem.lvlCount = eachItem.progreessFatherItemLvl()
        }
    }

    /// 循环处理所有事件，获得所有的frame
    @objc public func progressEachFrame() -> [CGRect] {
        var result: [CGRect] = []
        for eachItem in self.progressItems {
            let width = self.maxWidth / CGFloat(eachItem.lvlCount)
            let height = (eachItem.endTime.timeIntervalSince1970 - eachItem.startTime.timeIntervalSince1970) * 48 / 60 / 60
            let originY = CGFloat(eachItem.startTime.hours * 48 + eachItem.startTime.minutes * 48 / 60)
            let originX = width * CGFloat(eachItem.lvl)
            result.append(CGRect(x: originX, y: originY, width: width, height: CGFloat(height)))
        }
        
        return result
    }

}

/// 生成链表item的数据源
class OutLinkItemModel: NSObject {

    /// 事件的开始时间
    var startTime: Date!

    /// 事件的结束时间
    var endTime: Date!
}

/// 链表item
class LinkItem: NSObject {

    /// 事件的开始时间
    var startTime: Date!

    /// 事件的结束时间
    var endTime: Date!

    /// 当前item所在的层级, 最小为0
    var lvl: Int = 0

    /// 当前item链条中层级层数，最小为1
    var lvlCount: Int = 1

    /// 当前节点的父节点数组
    var fatherItems: [LinkItem] = []

    /// 当前节点的孩子节点数组
    var sonItems: [LinkItem] = []

    /// 为debug做的nickname
    // var debugNickName: String = ""

    /// 只处理开始时间和结束时间
    init(model: OutLinkItemModel) {
        self.startTime = model.startTime
        self.endTime = model.endTime
    }

    /// 与另外一个事件比较，是否时间上有交集
    func calculate2AnotherItemHaveSameTime(anotherItem: LinkItem) -> Bool {
        if self.endTime <= anotherItem.startTime || self.startTime >= anotherItem.endTime {
            return false
        }
        return true
    }

    /// 设置每一个item中lvlcount数值
    /// 处理每一个节点 ； 根据自己的孩子节点获得最底层孩子节点的lvl
    func progreessFatherItemLvl() -> Int {
        guard let firstSonItem = self.sonItems.first else {
            return self.lvl + 1
        }
        return firstSonItem.progreessFatherItemLvl()
    }
}

/// 链表item extension : comparable
extension LinkItem: Comparable {
    static func < (lhs: LinkItem, rhs: LinkItem) -> Bool {
        if lhs.startTime == rhs.startTime {
            if lhs.endTime == rhs.endTime {
                return true
            } else {
                return lhs.endTime.timeIntervalSince1970 < rhs.endTime.timeIntervalSince1970
            }
        } else {
            return lhs.startTime.timeIntervalSince1970 < rhs.startTime.timeIntervalSince1970
        }
    }

    static func == (lhs: LinkItem, rhs: LinkItem) -> Bool {
        return lhs.startTime == rhs.startTime && lhs.endTime == rhs.endTime
    }
}
