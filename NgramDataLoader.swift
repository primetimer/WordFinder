//
//  NgramDataLoader.swift
//  WordFinder
//
//  Created by Stephan Jancar on 04.01.18.
//

import Foundation
import UIKit

public enum NgramCorpus : Int {
	case english = 15
	case german = 20
	
}

public struct NgramEntry {
	
	private var _corpus : NgramCorpus!
	private var _year : Int!
	private var _relative : Double!
	private var _absolute : Double = -1.0
	
	init(corpus : NgramCorpus, year : Int, val : Double) {
		self._corpus = corpus
		self._year = year
		self._relative = val
		if let scale = NgramDataBase.shared.getabsValue(year: self._year, corpus: self._corpus) {
			_absolute = _relative * Double(scale.words)
		}
	}
	
	public var corpus : NgramCorpus {
		get { return _corpus }
	}
	public var year : Int {
		get { return _year }
	}
	public var relative: Double {
		get { return _relative }
	}
	public var absolue : Double {
		get { return _absolute }
	}
}

public class NgramData {
	
	private var _search : String!
	private var _corpus : NgramCorpus!
	private var _data : [NgramEntry]!
	
	public var search : String {
		get { return _search }
	}
	public var corpus : NgramCorpus {
		get { return _corpus }
	}
	public var data : [NgramEntry] {
		get { return _data }
	}
	
	init(corpus : NgramCorpus, search : String ,data : [NgramEntry])
	{
		self._corpus = corpus
		self._search = search
		self._data = data
	}
}



public class NGramLoader {
	
	private (set) var  DataRelative : [[Double]] = []
	
	private var search : String!
	private var start : Int = 1900
	private var end : Int = 2017
	
	//private let url = "https://books.google.com/ngrams/interactive_chart?content=113100%2C113110&year_start=1960&year_end=2017&corpus=15&smoothing=3"
	
	//private var url : String {
	//get { return ComputeURL(search : "abc") }
	//}
	
	private var base : NgramDataBase!
	public init() {
		base = NgramDataBase.shared
	}
	
	private let baseurl = "https://books.google.com/ngrams/interactive_chart?content="
	private func ComputeURL(search : String,start : Int, end : Int, corpus : NgramCorpus) -> URL? {
		let corpint = corpus.rawValue
		let url = baseurl + "\(search)&year_start=\(start)&year_end=\(end)&corpus=\(corpint)&smoothing=3"
		let ans = URL(string: url)
		return ans
	}
	public func LoadData(search : String, start : Int = 1900 , end : Int = 2017 , corpus : NgramCorpus = .english) -> NgramData? {
		guard let url = ComputeURL(search: search, start: start, end: end, corpus: corpus) else { return nil }
		let ddarr = loadData(url: url)
		guard let basedata = NgramDataBase.shared.getDict(corpus: corpus) else { return nil }
		var index = 0
		var entrys : [NgramEntry] = []
		for (year,base) in basedata.dict.sorted(by: {$0.0 < $1.0})
		{
			if year < start { continue }
			if year > end { continue }
			let data = NgramEntry(corpus: corpus, year: base.year, val: ddarr[0][index])
			entrys.append(data)
			index = index + 1
		}
		
		//Convert it corresponding to missing values
		let ans = NgramData(corpus: corpus, search: search, data: entrys)
		return ans
	}
	
	private func parsecontent(content : String, startIndex : String.Index) -> ([Double],String.Index?) {

		guard let start = content.range(of: "timeseries\": [", options: .literal, range: startIndex..<content.endIndex, locale: nil)
			else { return ([],nil) }
	
		//let trail = content[start.upperBound..<content.endIndex]
		guard let end = content.range(of: "]", options: .literal, range: start.upperBound..<content.endIndex,locale:nil)
			else { return ([],nil) }
		
		let found = content[start.upperBound..<end.lowerBound]
		let data = found.components(separatedBy: ", ")
		var dvaldata : [Double] = []
		for d in data {
			guard let dval = Double(d) else { break }
			dvaldata.append(dval)
		}
		return (dvaldata,end.upperBound)
	}
	
	
	//private var content = ""
	
	private func loadData(url : URL) -> [[Double]] {
		var ans : [[Double]] = []
		do {
			let content = try String(contentsOf: url)
			var index : String.Index? = content.startIndex
			var data : [Double] = []
			while index != nil {
				(data,index) = parsecontent(content: content,startIndex: index!)
				if data.count > 0  {
					ans.append(data)
				}
			}
		} catch {
			print("UUPS")
			// contents could not be loaded
		}
		return ans
	}
}
