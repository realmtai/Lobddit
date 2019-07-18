//
//  RedditModel.swift
//  Lobddit
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import Foundation

struct NewJSONResp: Codable {
    let content: Listing?
    
    private enum CodingKeys: String, CodingKey {
        case content = "data"
    }
    
}

struct Listing: Codable {
    let count: Int
    let children: [Child]
    
    private enum CodingKeys: String, CodingKey {
        case count = "dist"
        case children
    }
    
}

struct Child: Codable {
    let kind: String?
    let content: Article
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case content = "data"
    }
}

struct Article: Codable {
    let title: String?
    let url: URL?
    let thumbnail: URL?
    let thumbnailWidth: Double?
    let thumbnailHeight: Double?
    
    private enum CodingKeys: String, CodingKey {
        case url
        case thumbnail
        case title
        case thumbnailWidth = "thumbnail_width"
        case thumbnailHeight = "thumbnail_height"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try? values.decode(String.self, forKey: .title)
        url = try? values.decode(URL.self, forKey: .url)
        thumbnail = try? values.decode(URL.self, forKey: .thumbnail)
        thumbnailWidth = try? values.decode(Double.self, forKey: .thumbnailWidth)
        thumbnailHeight = try? values.decode(Double.self, forKey: .thumbnailHeight)
    }
    
}

