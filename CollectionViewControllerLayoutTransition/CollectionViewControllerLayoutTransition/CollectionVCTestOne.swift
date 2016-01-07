//
//  CollectionViewController.swift
//  CollectionVCLayoutTransitionDemo
//
//  Created by seedante on 15/12/23.
//  Copyright © 2015年 seedante. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class CollectionVCTestOne: UICollectionViewController {
    
    let pinchGesture = UIPinchGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let count = self.navigationController!.viewControllers.count
        self.title = "Level \(count)"
    }

    /*
    进行布局转场时，数据源的数量(section 和 cell 数量)要保持一致，尽管你可以在中途修改数量，但是回到最初的 CollectionViewController 时会出错。
    */
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        if indexPath.section == 0{
            cell.backgroundColor = UIColor.redColor()
        }else{
            cell.backgroundColor = UIColor.brownColor()
        }
    
        return cell
    }
    
    //MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //根据点击 cell 的位置来决定下一级的 CollectionView 的布局
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: indexPath.item * 10, height: indexPath.item * 10)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        let nextCVC = CollectionVCTestOne(collectionViewLayout: layout)
        nextCVC.useLayoutToLayoutNavigationTransitions = true
        navigationController?.pushViewController(nextCVC, animated: true)
    }
}
