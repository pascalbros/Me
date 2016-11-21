//
//  ViewController.swift
//  MeApp
//
//  Created by Pasquale Ambrosini on 20/11/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import UIKit

enum MyError: Error {
	case network
	case response
}

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		doIt()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	private func doIt() {
		Me.start { (me) in
			
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
		}.next { (caller, me) in
			guard let response = caller!.parameters["response"] as! String? else {
				me.parameters["error"] = MyError.response
				me.jump(toName: "errors")
				return
			}
			print("Response received. Length: \(response.characters.count)")
			me.end()
		}.next (name: "errors") { (caller, me) in
			let error = caller!.parameters["error"] as! MyError
			print("Error received. \(error.localizedDescription)")
			me.end()
		}.run()
	}


}

