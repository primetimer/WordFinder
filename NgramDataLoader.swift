//
//  NgramDataLoader.swift
//  WordFinder
//
//  Created by Stephan Jancar on 04.01.18.
//

import Foundation
import UIKit


extension String {
	var lines: [String] {
		var result: [String] = []
		enumerateLines { line, _ in result.append(line) }
		return result
	}
}

public class NGramLoader {
	
	private (set) var  DataRelative : [[Double]] = []
	
	private let url = "https://books.google.com/ngrams/interactive_chart?content=113100%2C113110&year_start=1960&year_end=2017&corpus=15&smoothing=3"
	
	private var base : NgramDataBase!
	public init() {
		base = NgramDataBase.shared
	}
	private func parsecount(startIndex : String.Index) -> String.Index? {
		guard let start = content.range(of: "timeseries\": [", options: .literal, range: startIndex..<content.endIndex, locale: nil)
			else { return nil }
		
		//let trail = content[start.upperBound..<content.endIndex]
		guard let end = content.range(of: "]", options: .literal, range: start.upperBound..<content.endIndex,locale:nil)
			else { return nil }
		
		let found = content[start.upperBound..<end.lowerBound]
		//print(found)
		
		let data = found.components(separatedBy: ", ")
		var dvaldata : [Double] = []
		for d in data {
			guard let dval = Double(d) else { break }
			dvaldata.append(dval)
		}
		DataRelative.append(dvaldata)
		return end.upperBound
	}
	private func parsecontent(startIndex : String.Index) -> String.Index? {
		guard let start = content.range(of: "timeseries\": [", options: .literal, range: startIndex..<content.endIndex, locale: nil)
			else { return nil }
	
		//let trail = content[start.upperBound..<content.endIndex]
		guard let end = content.range(of: "]", options: .literal, range: start.upperBound..<content.endIndex,locale:nil)
			else { return nil }
		
		let found = content[start.upperBound..<end.lowerBound]
		//print(found)
		
		let data = found.components(separatedBy: ", ")
		var dvaldata : [Double] = []
		for d in data {
			guard let dval = Double(d) else { break }
			dvaldata.append(dval)
		}
		DataRelative.append(dvaldata)
		return end.upperBound
	}
	
	
	private var content = ""
		
	public func loadData() {
		DataRelative = []
		if let url = URL(string: url ) {
			do {
				content = try String(contentsOf: url)
				var index : String.Index? = content.startIndex
				while index != nil {
					index = parsecontent(startIndex: index!)
				}
			} catch {
				print("UUPS")
				// contents could not be loaded
			}
		} else {
			print("Bad URL")
		}
	}
}
