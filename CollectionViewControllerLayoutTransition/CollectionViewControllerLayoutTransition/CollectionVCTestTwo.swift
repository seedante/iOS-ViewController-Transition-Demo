//
//  CollectionViewControllerTestTwo.swift
//  CollectionViewControllerLayoutTransition
//
//  Created by seedante on 16/1/7.
//  Copyright © 2016年 seedante. All rights reserved.
//

import UIKit

/*
通过单例的数据源来测试布局转场在修改数据源下的表现，测试表明，这很不稳定，建议不要这么做。在 storyboard 将类切换到 CollectionVCTestTwo 便可以测试这种情况
*/
class CollectionVCTestTwo: UICollectionViewController {
    
    var dataSource = CollectionViewDataSource.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = dataSource
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let count = self.navigationController!.viewControllers.count
        self.title = "Level \(count)"
    }
    
    //根据点击 cell 的位置来决定下一级的 CollectionView 的布局
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: indexPath.item * 10, height: indexPath.item * 10)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        //随机更改 cell 的数量
        dataSource.cellCount = Int(UInt32(arc4random()) % UInt32(10)) + 5
        let nextCVC = CollectionVCTestTwo(collectionViewLayout: layout)
        nextCVC.useLayoutToLayoutNavigationTransitions = true
        navigationController?.pushViewController(nextCVC, animated: true)
    }
}

class CollectionViewDataSource:NSObject, UICollectionViewDataSource {

    let reuseIdentifier = "Cell"
    static let sharedInstance = CollectionViewDataSource()
    
    var sectionCount = 2
    var cellCount = 15
    
    private override init() {}
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellCount
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath)
        if indexPath.section == 0{
            cell.backgroundColor = UIColor.red
        }else{
            cell.backgroundColor = UIColor.brown
        }
        
        return cell
    }
}
