//
//  LobdditTests.swift
//  LobdditTests
//
//  Created by PersonA on 7/18/19.
//  Copyright © 2019 Michael Tai. All rights reserved.
//

import XCTest
@testable import Lobddit

class LobdditTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodingArticle() {
        let articleJSON =
"""
        {
          "approved_at_utc": null,
          "subreddit": "swift",
          "selftext": "",
          "author_fullname": "t2_28u4w6s7",
          "downs": 0,
          "thumbnail_height": 93,
          "hide_score": false,
          "thumbnail_width": 140,
          "author_flair_template_id": null,
          "is_original_content": false,
          "user_reports": [
          ],
          "thumbnail": "https://b.thumbs.redditmedia.com/YzrK1u42GX-JLFesQ8Sxv_vmIiP5gPNkVpf7eQw5zSo.jpg",
          "edited": false,
          "author_patreon_flair": false,
          "author_flair_text_color": null,
          "permalink": "/r/swift/comments/ceq95k/we_are_launching_a_community_with_a_project/",
          "parent_whitelist_status": "all_ads",
          "stickied": false,
          "url": "https://i.redd.it/gr6p4lb471b31.png",
          "subreddit_subscribers": 48881,
          "created_utc": 1563442340.0,
          "discussion_type": null,
          "media": null,
          "is_video": false
        }
""".data(using: .utf8)!
        guard let article = try? JSONDecoder().decode(Article.self, from: articleJSON) else {
            XCTAssertTrue(false, "Unable to decode articleJSON")
            return
        }
        XCTAssertEqual(article.thumbnailWidth!, 140)
        XCTAssertEqual(article.thumbnailHeight!, 93)
        XCTAssertEqual(article.thumbnail!.absoluteString, "https://b.thumbs.redditmedia.com/YzrK1u42GX-JLFesQ8Sxv_vmIiP5gPNkVpf7eQw5zSo.jpg")
        XCTAssertEqual(article.url!.absoluteString, "https://i.redd.it/gr6p4lb471b31.png")
    }
    
    func testDecodingRSwiftNew() {
        let jsonURL = Bundle(for: type(of: self)).url(forResource: "testDataNormal", withExtension: "json")!
        let rswiftRespData = try! Data(contentsOf: jsonURL)
        guard let rswiftRespJSON = try? JSONDecoder().decode(NewJSONResp.self, from: rswiftRespData) else {
            XCTAssertTrue(false, "Unable to decode articleJSON")
            return
        }
        XCTAssertNotNil(rswiftRespJSON.content)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
