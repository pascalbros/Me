//
//  Me.swift
//  Test1
//
//  Created by Pasquale Ambrosini on 20/11/16.
//  Copyright © 2016 Pasquale Ambrosini. All rights reserved.
//

import Foundation

public typealias MeInitClosure = ((_ current: Me) -> ())
public typealias MeClosure = ((_ previous: Me?, _ current: Me) -> ())

public class Me: NSObject {
	
	private var this: MeClosure!
	private var next: MeClosure?
	private var nextObj: Me?
	private var _first: Me?
	public var first: Me {
		get {
			if let first = self._first {
				return first
			}else{
				return self
			}
		}
	}
	
	private var _index: UInt = 0
	public var index: UInt {
		get { return self._index }
	}
	
	private var _name: String = ""
	var name: String {
		get { return _name }
	}
	
	public var parameters: [String: Any] = [:]
	
	private init(name: String = "", index: UInt, this: @escaping MeClosure) {
		super.init()
		self.this = this
		self._index = index
		if name == "" {
			self._name = String(self.index)
		}else{
			self._name = name
		}
	}
	
	public static func start(name: String = "", this: @escaping MeInitClosure) -> Me {
		let me = Me(name: name, index: 0, this: { (nil, self) -> (Void) in
			this(self)
		})
		return me
	}
	
	public static func run(this: @escaping MeClosure) -> Me {
		let me = Me(index: 0, this: this)
		me._index = 0
		this(nil, me)
		return me
	}
	
	public func next(name: String = "", next: @escaping MeClosure) -> Me {
		self.next = next
		self.nextObj = Me(name: name, index: self.index + 1, this: next)
		self.nextObj!._first = self.first
		return self.nextObj!
	}
	
	deinit {
		self.parameters.removeAll()
		//print("deinit \(self.name)")
	}
	
	public func run() {
		self.first.this(nil, self.first)
	}
	
	public func end() {
		var tempMe: Me? = self.first
		while let me = tempMe {
			guard let next = me.nextObj else{ return }
			tempMe = next
			me._first = nil
			me.nextObj = nil
		}
	}
	
	public func runNext(queue: DispatchQueue) {
		if let next = self.next {
			//self.nextObj!.parameters = self.parameters //enable to pass parameters to the next object
			queue.async {
				next(self, self.nextObj!)
			}
		}
	}
	
	public func runNext() {
		self.runNext(queue: DispatchQueue.global())
	}
	public func runNextOnMain() {
		self.runNext(queue: DispatchQueue.main)
	}
	
	private func me(at name: String) -> Me? {
		var tempMe: Me? = self.first
		while let me = tempMe {
			if me.name == name {
				return me
			}
			guard let next = me.nextObj else{ return nil }
			tempMe = next
		}
		return nil
	}
	
	private func me(at index: UInt) -> Me? {
		var tempMe = self.first
		for _ in 0..<index {
			guard let next = tempMe.nextObj else{ return nil }
			tempMe = next
		}
		return tempMe
	}
	
	// MARK: Jump using the index
	
	public func jump(toIndex jump: UInt = 0, queue: DispatchQueue) {
		if let to = me(at: jump) {
			to.this(self, to)
		}
	}
	
	public func jump(toIndex jump: UInt = 0) {
		self.jump(toIndex: jump, queue: DispatchQueue.global())
	}
	
	public func jumpOnMain(toIndex jump: UInt = 0) {
		self.jump(toIndex: jump, queue: DispatchQueue.main)
	}
	
	// MARK: Jump using the identifier
	
	public func jump(toName jump: String, queue: DispatchQueue) {
		if let to = me(at: jump) {
			to.this(self, to)
		}
	}
	
	public func jump(toName jump: String) {
		self.jump(toName: jump, queue: DispatchQueue.global())
	}
	
	public func jumpOnMain(toName jump: String) {
		self.jump(toName: jump, queue: DispatchQueue.main)
	}
}
