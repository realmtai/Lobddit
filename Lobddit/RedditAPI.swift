//
//  RedditAPI.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import Foundation

enum RedditEndPoint: String {
    case swift = "https://www.reddit.com/r/swift/new.json?sort=new&limit=100"
}

class RedditAPI {
    
    let workQueue = DispatchQueue(label: "com.michael.tai.RedditAPI.workq")
    
    fileprivate func translate(RedditEndPoint endpoint: RedditEndPoint) -> URL {
        switch endpoint {
        case .swift: return URL(string: endpoint.rawValue)!
        }
    }
    
    func getArticles(_ endpoint: RedditEndPoint, andResult action: @escaping (Result<[Article], Error>)->() )  {
        let url = translate(RedditEndPoint: endpoint)
        AF.request(url).responseData { [weak self] response in
            self?.workQueue.async {
                if let data = response.data {
                    let parseError = NSError(domain:"com.michael.tai.RedditAPI.workq.error",
                                             code:response.response?.statusCode ?? 0,
                                             userInfo:[NSDebugDescriptionErrorKey: "parse error, check the unit test"])
                    
                    guard let jsonResp = try? JSONDecoder().decode(NewJSONResp.self, from: data).content else {
                        action(.failure(parseError))
                        return
                    }
                    let articles = jsonResp.children.map({ $0.content })
                    action(.success(articles))
                } else {
                    let error = response.error
                                ?? NSError(domain:"com.michael.tai.RedditAPI.workq.error",
                                           code:response.response?.statusCode ?? 0,
                                           userInfo:nil)
                    action(.failure(error))
                }
            }
        }
    }
    
}
