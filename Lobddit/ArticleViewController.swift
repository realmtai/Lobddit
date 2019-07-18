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
    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }
    
    func loadContent() {
        if let url = article?.url {
            webview.load(URLRequest(url: url))
        }
        if let thumbnailURL = article?.thumbnail {
            iconImageView.hnk_setImage(from: thumbnailURL) 
        }
    }
    
}
