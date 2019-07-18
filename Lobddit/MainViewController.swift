//
//  MainViewController.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    fileprivate let api = RedditAPI()
    fileprivate let workQueue = DispatchQueue(label: "com.michael.tai.mainviewcontroller.workq")
    
    fileprivate var dataStore: [Article] = [] {
        didSet {
            DispatchQueue.main.async {
                
            }
        }
    }
    
    
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

