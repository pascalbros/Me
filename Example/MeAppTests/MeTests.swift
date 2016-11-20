//
//  MeAppTests.swift
//  MeAppTests
//
//  Created by Pasquale Ambrosini on 20/11/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import XCTest
@testable import MeApp

class MeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testWebpageDownload() {
		let expectation = self.expectation(description: "Expectation")
		var testError: MyError?
		
		Me.start { (me) -> (Void) in
			
			let url = URL(string: "http://www.stackoverflow.com")
			let task = URLSession.shared.dataTask(with: url! as URL) { data, response, error in
				
				guard let data = data, error == nil else {
					me.parameters["error"] = MyError.network
					me.jump(toName: "errors")
					return
				}
				
				me.parameters["response"] = String(data: data, encoding: .utf8)
				me.runNext()
			}
			
			task.resume()
		}.next { (caller, me) -> (Void) in
			guard let response = caller!.parameters["response"] as! String? else {
				me.parameters["error"] = MyError.response
				me.jump(toName: "errors")
				return
			}
			print("Response received. Length: \(response.characters.count)")
			me.end()
			expectation.fulfill()
		}.next (name: "errors") { (caller, me) -> (Void) in
			let error = caller!.parameters["error"] as! MyError
			print("Error received. \(error.localizedDescription)")
			me.end()
			testError = error
			expectation.fulfill()
		}.run()
		
		waitForExpectations(timeout: 10, handler: nil)
		if let error = testError {
			XCTFail(error.localizedDescription)
		}
    }
    
}
