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
        set(newValue) {
            textLabel.text = newValue
            textLabel.sizeToFit()
        }
    }
    
    var imageURL: URL? {
        get { return nil }
        set(newValue) {
            if let imageURL = newValue, imageURL.isHttps {
                thumbnailImage.hnk_setImage(from: imageURL)
                thumbnailImage.isHidden = false
            } else {
                thumbnailImage.isHidden = true
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
    
    private let collctionViewMagicConstant: CGFloat = 140
    
    //MARK:- UI Elements
    //MARK:

    @IBOutlet weak var mainCollectionView: UICollectionView! {
        didSet {
        }
    }
    
    
    //MARK:- Life Cycle
    //MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mainCollectionView.collectionViewLayout = collectionViewLayout(forSize: view.frame.size)
        mainCollectionView.collectionViewLayout.invalidateLayout()
        self.workQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ArticleViewController, let datum = sender as? Article {
            destVC.article = datum
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainCollectionView.collectionViewLayout = collectionViewLayout(forSize: size)
        mainCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK:- Actions
    //MARK:
    
    func fetchData() {
        DispatchQueue.main.async {
            APESuperHUD.show(style: .loadingIndicator(type: .standard), title: "Loading", message: nil, completion: nil)
        }
        api.getArticles(.swift) {[weak self] result in
            self?.workQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let articles):
                    strongSelf.dataStore = articles
                    DispatchQueue.main.async {
                        APESuperHUD.dismissAll(animated: true)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        APESuperHUD.show(style: .textOnly, title: "Error",
                                         message: error.localizedDescription,
                                         completion: nil)
                    }
                }
            }
        }
    }
    
    func showDetail(for article: Article) {
        performSegue(withIdentifier: "gotoArticleViewController", sender: article)
    }
    
    func collectionViewLayout(forSize size: CGSize) -> CHTCollectionViewWaterfallLayout {
        let layout = CHTCollectionViewWaterfallLayout()
        let width = size.width
        layout.columnCount = Int(width/collctionViewMagicConstant)
        return layout
    }

}


extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let datum = dataStore[indexPath.row]
        showDetail(for: datum)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataStore.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionCell.id, for: indexPath) as? MainCollectionCell else {
            return UICollectionViewCell(frame: .zero)
        }
        let datum = dataStore[indexPath.row]
        cell.text = datum.title ?? ""
        cell.imageURL = datum.thumbnail
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let datum = dataStore[indexPath.row]
        let text = datum.title ?? ""
        let height = text.height(withConstrainedWidth: collctionViewMagicConstant, font: UIFont.systemFont(ofSize: 18, weight: .regular))
        return CGSize(width: collctionViewMagicConstant, height: height)
    }
    
    
}
