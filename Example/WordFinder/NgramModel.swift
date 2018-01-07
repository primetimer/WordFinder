//
//  NgramModel.swift
//  WordFinder_Example
//
//  Created by Stephan Jancar on 07.01.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import WordFinder

class NgramParam {
	static let shared = NgramParam()
	var absolute : Bool = false
	
	private init() {
		
	}
}

class NgramModel {
	private lazy var loader = NGramLoader()
	var data : [NgramData] = []
	
	func clean() {
		var n = data.count-1
		while n > 0 {
			if data[n].search == "" {
				data.remove(at: n)
			}
			n = n - 1
		}
		if data.count == 0 {
			appendSearch(search: "Example")
		}
	}
	
	func appendSearch(search : String) {
		if let loaddata = loader.LoadData(search: search) {
			data.append(loaddata)
		}
	}
	func refreshSearch(search : String, row : Int) {
		if let loaddata = loader.LoadData(search: search) {
			data[row] = loaddata
		}
	}
	func GetSearchString(row : Int) -> String {
		if row >= data.count { return "" }
		let ans = data[row].search
		return ans
	}
	func move(from : Int, to: Int)
	{
		let src = data[from]
		data.remove(at: from)
		data.insert(src, at: to)
	}
}
