//
//  NgramDataBase.swift
//  WordFinder
//
//  Created by Stephan Jancar on 05.01.18.
//

import Foundation


public struct NgramBase {
	public var year: Int = 0
	public var words : Int = 0
	public var pages : Int = 0
	public var volumes : Int = 0
}

public class NgramDict {
	
	var corpus : NgramCorpus!
	var dict : [Int:NgramBase]!

	init(corpus : NgramCorpus) {
		self.corpus = corpus
		dict = [:]
	}
	func append(data : NgramBase) {
		if data.year > 0 {
			dict[data.year] = data
		}
	}
	func getData(year : Int) -> NgramBase? {
		return dict[year]
	}
}

//Retrieves absolute count Values by google in all corpi
public class NgramDataBase  {
	public let allcorpus : [NgramCorpus] = [.english, .german]

	//Singleton
	static public let shared = NgramDataBase()
	private (set) var loaded = false
	private (set) var error : Error? = nil
	
	private var corpusdict : [NgramCorpus:NgramDict] = [:]
	private (set) var urls : [NgramCorpus:String] = [:]
	
	public func getDict(corpus : NgramCorpus = .english) -> NgramDict? {
		if !loaded { return nil }
		let dict = corpusdict[corpus]
		return dict
	}
	public func getabsValue(year : Int, corpus : NgramCorpus = .english) -> NgramBase? {
		if !loaded { return nil }
		if let dict = corpusdict[corpus] {
			let val = dict.dict[year]
			return val
		}
		return nil
	}
	
	public init() {
		urls[.english] = "https://storage.googleapis.com/books/ngrams/books/googlebooks-eng-all-totalcounts-20120701.txt"
		urls[.german] = "https://storage.googleapis.com/books/ngrams/books/googlebooks-ger-all-totalcounts-20120701.txt"
		load()
	}
	
	public func load(reload : Bool = false) {
		if reload { loaded = false }
		if loaded { return }
		
		corpusdict = [:]
		error = nil
		for corpus in allcorpus {
			if let dict = loadCount(corpus: corpus) {
				corpusdict[corpus] = dict
			}
		}
		if corpusdict.count == urls.count && error == nil {
			loaded = true
		}
	}
	
	private func loadCount(corpus : NgramCorpus) -> NgramDict? {
		let ans = NgramDict(corpus: corpus)
		guard let urlstr = urls[corpus] else { return nil}
		guard let url = URL(string : urlstr) else { return nil }
		do {
			let countstr = try String(contentsOf: url)
			let rows =  countstr.components(separatedBy: "\t")
			for row in rows {
				let vals = row.components(separatedBy: ",")
				if vals.count != 4 { continue }
				if let year = Int(vals[0]), let words = Int(vals[1]), let pages = Int(vals[2]), let vol = Int(vals[3]) {
					let entry = NgramBase(year: year, words: words, pages: pages, volumes: vol)
					ans.append(data: entry)
				}
			}
		}
		catch let error {
			// Error handling
			self.error = error
			print(error)
		}
		return ans
	}
}

