//
//  Utility.swift
//  ipad_scrollapp
//
//  Created by miyata ginga on 2020/01/06.
//  Copyright © 2020 com.miyagin.ipad_scroll. All rights reserved.
//

import Foundation
import UIKit
class Utility {
    static let goalPositionInt: [Int] = [10, 11, 12, 11, 10, 20, 50, 20, 10]
    // y = x/(max-min)+min/(min-max)
    class func faceAURangeChange(faceAUVertex: Float, maxFaceAUVertex: Float, minFaceAUVertex: Float) -> Float {
        let faceAUChangeValue = faceAUVertex / (maxFaceAUVertex - minFaceAUVertex) + minFaceAUVertex / (minFaceAUVertex - maxFaceAUVertex)
        return faceAUChangeValue
    }

    class func createScrollView(directionString: String) -> UICollectionView {
        var myCollectionView: UICollectionView!
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        if directionString == "horizonal" {
            // Cell一つ一つの大きさ.
            layout.itemSize = CGSize(width: 100, height: 600)
            layout.minimumLineSpacing = 0.1
            // Cellのマージン.
            // layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.scrollDirection = .horizontal

            // layout.scrollDirection = .vertical

            // セクション毎のヘッダーサイズ.
            // layout.headerReferenceSize = CGSize(width:10,height:30)
            // CollectionViewを生成.
            // myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 150, width: 600, height: 600),
                                                collectionViewLayout: layout)
            myCollectionView.backgroundColor = UIColor.white
            // Cellに使われるクラスを登録.
            myCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
            myCollectionView.contentSize = CGSize(width: 1800, height: 600)
        } else if directionString == "vertical" {
            // Cell一つ一つの大きさ.
            layout.itemSize = CGSize(width: 600, height: 100)
            layout.minimumLineSpacing = 0.1
            // Cellのマージン.
            // layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            // layout.scrollDirection = .horizontal

            layout.scrollDirection = .vertical

            // セクション毎のヘッダーサイズ.
            // layout.headerReferenceSize = CGSize(width:10,height:30)
            // CollectionViewを生成.
            // myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
            myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 150, width: 600, height: 600),
                                                collectionViewLayout: layout)
            myCollectionView.backgroundColor = UIColor.white
            // Cellに使われるクラスを登録.
            myCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
            myCollectionView.contentSize = CGSize(width: 600, height: 1800)
        }
        return myCollectionView
    }

    class func createGoalView(directionString: String) -> UIView {
        let goalView = UIView()
        if directionString == "horizonal" {
            goalView.frame = CGRect(x: 200, y: 150, width: 150, height: 700)
        } else if directionString == "vertical" {
            goalView.frame = CGRect(x: 0, y: 350, width: 700, height: 150)
        }
        goalView.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0.8, alpha: 0.5)
        return goalView
    }
}
