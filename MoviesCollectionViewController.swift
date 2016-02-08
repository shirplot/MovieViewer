//
//  MoviesCollectionViewController.swift
//  MovieViewer
//
//  Created by Shirley Plotnik on 2/5/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit



class MoviesCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    @IBOutlet var collectionView : UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 90, height: 90)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView!.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView!)
    }

    
}
