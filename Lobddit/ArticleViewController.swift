//
//  ArticleViewController.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import Foundation
import WebKit

class ArticleViewController: UIViewController {
    
    var article: Article? = nil
    
    //MARK:- UI Elements
    //MARK:

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webview: WKWebView! {
        didSet { webview.navigationDelegate = self }
    }
    
    
    //MARK:- Life Cycle
    //MARK:

    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(article != nil, "Should never be here without an article to display!!!")
        
        DispatchQueue.main.async {
            self.loadContent()
        }
    }
    
    
    //MARK:- Actions
    //MARK:
    
    func loadContent() {
        APESuperHUD.show(style: .loadingIndicator(type: .standard), title: nil, message: "Loading", completion: nil)
        
        if let title = article?.title {
            self.navigationItem.title = title
        }
        if let url = article?.url {
            webview.load(URLRequest(url: url))
        }
        if let thumbnailURL = article?.thumbnail,
            let thumbnailWidth = article?.thumbnailWidth,
            let thumbnailHeight = article?.thumbnailHeight,
            thumbnailURL.isHttps {
            iconImageView.hnk_setImage(from: thumbnailURL)
            iconWidthConstraint.constant = CGFloat(thumbnailWidth)
            iconHeightConstraint.constant = CGFloat(thumbnailHeight)
        } else {
            iconImageView.isHidden = true
        }
    }
    
    @IBAction func requestRefresh(_ sender: UIBarButtonItem) {
        if webview.isLoading { return }
        loadContent()
    }
    
}


extension ArticleViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            APESuperHUD.show(style: .textOnly, title: "Yikes...", message: error.localizedDescription, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            APESuperHUD.dismissAll(animated: true)
        }
    }
    
}
