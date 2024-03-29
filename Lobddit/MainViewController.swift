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
    @IBOutlet weak var thumbnailHeightConstraint: NSLayoutConstraint!
    
    
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
    
    var thumbnailHeight: CGFloat {
        get { return thumbnailHeightConstraint.constant }
        set(newValue) { thumbnailHeightConstraint.constant = newValue }
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
            mainCollectionView.refreshControl = collectionViewRefreshControl()
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
            APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Loading", completion: nil)
            self.mainCollectionView.refreshControl = nil
        }
        api.getArticles(.swift) {[weak self] result in
            self?.workQueue.async { [weak self] in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let articles):
                    strongSelf.dataStore = articles
                    DispatchQueue.main.async {
                        APESuperHUD.dismissAll(animated: true)
                        strongSelf.mainCollectionView.refreshControl = strongSelf.collectionViewRefreshControl()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        APESuperHUD.show(style: .textOnly, title: "Yikes...",
                                         message: error.localizedDescription,
                                         completion: nil)
                        strongSelf.mainCollectionView.refreshControl = strongSelf.collectionViewRefreshControl()
                    }
                }
            }
        }
    }
    
    @objc func requestDataRefresh(_ sender: UIRefreshControl) {
        fetchData()
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
    
    func collectionViewRefreshControl() -> UIRefreshControl {
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(requestDataRefresh(_:)), for: .valueChanged)
        return refreshControl
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionCell.id,
                                                            for: indexPath) as? MainCollectionCell,
            let layout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout else {
            return UICollectionViewCell(frame: .zero)
        }
        let cellWidth = Double(layout.itemWidth(inSection: indexPath.section))
        let datum = dataStore[indexPath.row]
        
        cell.text = datum.title ?? ""
        if let imgHeight = datum.thumbnailHeight,
            let imgWidth = datum.thumbnailWidth {
            cell.thumbnailHeight = CGFloat((cellWidth * imgHeight) / imgWidth)
        }
        cell.imageURL = datum.thumbnail
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let datum = dataStore[indexPath.row]
        guard let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout,
            let text = datum.title else {
            return .zero
        }
        
        let cellWidth = layout.itemWidth(inSection: indexPath.section)
        let textHeight = text.height(withConstrainedWidth: cellWidth, font: UIFont.systemFont(ofSize: 17, weight: .regular))
        var thumbnailHeight: CGFloat = 0
        if let url = datum.thumbnail, url.isHttps {
            let imgHeight = CGFloat(datum.thumbnailHeight ?? 0)
            let imgWidth = CGFloat(datum.thumbnailWidth ?? 1)
            thumbnailHeight = CGFloat((cellWidth * imgHeight) / imgWidth)
        }
        return CGSize(width: cellWidth, height: textHeight+thumbnailHeight)
    }
    
    
}
