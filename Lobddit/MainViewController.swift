//
//  MainViewController.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import UIKit

class MainCollectionCell: UICollectionViewCell {
    static let id: String = "MainCollectionCell"
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    var text: String {
        get { return textLabel.text ?? "" }
        set(newValue) { textLabel.text = newValue }
    }
    
    var imageURL: URL? {
        get { return nil }
        set(newValue) {
            thumbnailImage.isHidden = (newValue == nil)
            if let imageURL = newValue {
                thumbnailImage.hnk_setImage(from: imageURL)
            }
        }
    }
    
    override func prepareForReuse() {
        thumbnailImage.hnk_cancelSetImage()
        super.prepareForReuse()
    }
    
}

class MainViewController: UIViewController {
    
    fileprivate let api = RedditAPI()
    fileprivate let workQueue = DispatchQueue(label: "com.michael.tai.mainviewcontroller.workq")
    
    fileprivate var dataStore: [Article] = [] {
        didSet { DispatchQueue.main.async { self.mainCollectionView.reloadData() } }
    }
    
    //MARK:- UI Elements
    //MARK:

    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    
    //MARK:- Life Cycle
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchData()
        }
    }
    
    //MARK:- Actions
    //MARK:
    
    func fetchData() {
        api.getArticles(.swift) {[weak self] result in
            self?.workQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let articles):
                    strongSelf.dataStore = articles
                case .failure(let error):
                    // Do something here
                    break
                }
            }
        }
    }
    



}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionCell.id, for: indexPath) as? MainCollectionCell else {
            return UICollectionViewCell(frame: .zero)
        }
        let data = dataStore[indexPath.row]
        cell.text = data.title ?? ""
        cell.imageURL = data.thumbnail
        return cell
    }
    
}
