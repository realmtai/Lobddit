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
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var webview: WKWebView! {
        didSet { webview.navigationDelegate = self }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(article != nil)
        DispatchQueue.main.async {
            self.loadContent()
        }
    }
    
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
    
}

extension ArticleViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            APESuperHUD.dismissAll(animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            APESuperHUD.dismissAll(animated: true)
        }
    }
    
}
