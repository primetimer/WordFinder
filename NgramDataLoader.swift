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
	
	public var str : String {
		get {
			switch self {
			case .english:
				return "english"
			case .german:
				return "german"
			}
		}
	}
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

public class NgramData : Hashable {
	public static func ==(lhs: NgramData, rhs: NgramData) -> Bool {
		return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
	}
	public var hashValue: Int {
		return ObjectIdentifier(self).hashValue
	}

	
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
	
	private var smoothing = 1
	private var _smooth : [NgramEntry] = []
	private var _delta : [NgramEntry] = []
	
	public func SmoothValues(smoothing : Int) -> [NgramEntry] {
		self.smoothing = smoothing
		_smooth = []
		if _data.count == 0 { return [] }
		_smooth.append(data[0])
		if data.count == 1 { return _smooth }
		for index in 1..<data.count {
			let startindex = index - smoothing
			var (sum,divisor) = (0.0,0.0)
			for j in max(0,startindex)...index {
				sum = sum + data[j].relative
				divisor = divisor + 1.0
			}
			let avg = sum / divisor
			let entry = NgramEntry(corpus: self.corpus, year: data[index].year, val: avg)
			_smooth.append(entry)

		}
		return _smooth
	}
	
	public func DeltaValues() -> [NgramEntry] {
		_delta = []
		if data.count == 0 { return _delta }
		let nullentry = NgramEntry(corpus: self.corpus, year: data[0].year, val: 0)
		_delta.append(nullentry)
		if data.count == 1 { return _data }
	
		for index in 1..<data.count {
			let delta = data[index].relative - data[index-1].relative
			let entry = NgramEntry(corpus: self.corpus, year: data[index].year, val: delta)
			_delta.append(entry)
		}
		return _delta
	}
	
	init(corpus : NgramCorpus, search : String ,data : [NgramEntry])
	{
		self._corpus = corpus
		self._search = search
		self._data = data
	}
}

public class NgramDataZero : NgramData {
	public init(corpus : NgramCorpus = .english, search : String = "")
	{
		super.init(corpus: corpus, search : search, data : [])
	}
}



public class NGramLoader {
	
	private (set) var  DataRelative : [[Double]] = []
	
	private var search : String!
	private var start : Int = 1900
	private var end : Int = 2017
	var smoothing = 0
	
	private var base : NgramDataBase!
	public init() {
		base = NgramDataBase.shared
	}
	
	/*
	private let baseurl = "https://books.google.com/ngrams/interactive_chart?content="
	private func ComputeURL(search : String,start : Int, end : Int, corpus : NgramCorpus) -> URL? {
		let corpint = corpus.rawValue
		let url = baseurl + "\(search)&year_start=\(start)&year_end=\(end)&corpus=\(corpint)&smoothing=\(smoothing)"
		let ans = URL(string: url)
		return ans
	}
	*/
	//private let baseurl = "https://books.google.com/ngrams/graph?content=%28%28Bigfoot+%2B+Sasquatch%29+-+%28Loch+Ness+monster+%2B+Nessie%29%29&year_start=1900&year_end=2000&corpus=15&smoothing=0&share=&direct_url=t1%3B%2C%28%28Bigfoot%20%2B%20Sasquatch%29%20-%20%28Loch%20Ness%20monster%20%2B%20Nessie%29%29%3B%2Cc0"
	private let baseurl = "https://books.google.com/ngrams/graph?content="
	
	private func ComputeURL(search : String,start : Int, end : Int, corpus : NgramCorpus) -> URL? {
		let corpint = corpus.rawValue
		let url = baseurl + "\(search)&year_start=\(start)&year_end=\(end)&corpus=\(corpint)&smoothing=\(smoothing)"
		let ans = URL(string: url)
		return ans
	}
	
	private func PrepareSearchString(str: String) -> String {
		//Ersetze blank durch +
		//ersetze - durch " - " -> "+-+"
		//vorher ersetze + durch %2B
		let r0 = str //"((Bigfoot + Sasquatch) - (Loch Ness monster + Nessie))"
		let r1 = r0.replacingOccurrences(of: "(", with: "%28",options: .literal, range:nil)
		let r2 = r1.replacingOccurrences(of: ")", with: "%29",options: .literal, range:nil)
		let r3 = r2.replacingOccurrences(of: "+", with: "%2B",options: .literal, range: nil)
		let r4 = r3.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
		return r4
	}
	
	public func LoadData(search : String, start : Int = 1900 , end : Int = 2017 , corpus : NgramCorpus = .english) -> NgramData? {
		let prepared = PrepareSearchString(str: search)
		guard let url = ComputeURL(search: prepared, start: start, end: end, corpus: corpus) else { return nil }
		let ddarr = loadData(url: url)
		if ddarr.count == 0 { return NgramDataZero(corpus: corpus, search: search) }
		guard let basedata = NgramDataBase.shared.getDict(corpus: corpus) else { return nil }
		var index = 0
		var entrys : [NgramEntry] = []
		for (year,base) in basedata.dict.sorted(by: {$0.0 < $1.0})
		{
			if year < start { continue }
			if year > end { continue }
			if index>=ddarr[0].count { break }
			let data = NgramEntry(corpus: corpus, year: base.year, val: ddarr[0][index])
			entrys.append(data)
			index = index + 1
		}
		
		//Convert it corresponding to missing values
		let ans = NgramData(corpus: corpus, search: search, data: entrys)
		return ans
	}
	
	public func LoadContinuations(search : String, start : Int = 1900 , end : Int = 2017 , corpus : NgramCorpus = .english) -> [String] {
		let prepared = PrepareSearchString(str: search+" *")
		guard let url = ComputeURL(search: prepared, start: start, end: end, corpus: corpus) else { return [] }
		
		let cont = loadContinuations(url: url)
		return cont
	}
	
	private func parsecontent(content : String, startIndex : String.Index) -> ([Double],String.Index?) {
		guard let start = content.range(of: "timeseries\": [", options: .literal, range: startIndex..<content.endIndex, locale: nil)
			else { return ([],nil) }
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
	
	private func loadContinuations(url : URL) -> [String] {
		var ans : [String] = []
		do {
			let content = try String(contentsOf: url)
			var index : String.Index? = content.startIndex
			var str : String?
			while index != nil {
				(str,index) = parsecontinuatione(content: content, startIndex: index!)
				if str != nil  {
					ans.append(str!)
				}
			}
		} catch {
			print("UUPS")
			// contents could not be loaded
		}
		return ans
	}
	private func parsecontinuatione(content : String, startIndex : String.Index) -> (String?,String.Index?) {
	
		guard let start = content.range(of: "ngram\": \"", options: .literal, range: startIndex..<content.endIndex,locale: nil)
			else { return (nil,nil) }
		guard let end = content.range(of: "\"",options: .literal, range: start.upperBound..<content.endIndex,locale: nil)
		else { return (nil,nil) }
		let subans = content[start.upperBound..<end.lowerBound]
		let ans = String(subans)
		return (ans,end.upperBound)
	}
	
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
