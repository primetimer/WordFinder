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
	var smoothing : Int = 3
	var delta : Int = 0
	var graphexpanded = false
	private init() {		
	}
}

class NgramModel {
	private lazy var loader = NGramLoader()
	var data : [NgramData] = []
	
	func cleanup() {
		var n = data.count-1
		while n > 0 {
			if data[n].search == "" {
				data.remove(at: n)
			}
			n = n - 1
		}
		if data.count == 0 {
			_ = appendSearch(search: "Example")
		}
	}
	
	func appendSearch(search : String) -> NgramData? {
		if let loaddata = loader.LoadData(search: search) {
			data.append(loaddata)
			return loaddata
		}
		return nil
	}
	func refreshSearch(search : String, row : Int) -> NgramData? {
		if let loaddata = loader.LoadData(search: search) {
			data[row] = loaddata
		}
		return data[row]
	}
	
	func refeshSearch(search : String, data : NgramData) -> NgramData? {
		for i in 0..<self.data.count {
			if self.data[i] == data {
				return refreshSearch(search: search, row: i)
			}
		}
		return appendSearch(search: search)
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
