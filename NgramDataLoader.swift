//
//  NgramDataLoader.swift
//  WordFinder
//
//  Created by Stephan Jancar on 04.01.18.
//

import Foundation
import UIKit


public class NGramLoader {
	
	private (set) var  Data : [[Double]] = []
	
	public init() {}
	/*
	private var iframe : String {
	get {
	return "<iframe name=\"ngram_chart\" src=\"https://books.google.com/ngrams/interactive_chart?content=113100%2C113110&year_start=1960&year_end=2017&corpus=15&smoothing=3\" width=400 height=400 marginwidth=0 marginheight=0 hspace=0 vspace=0 frameborder=0 scrolling=yes></iframe>"
	}
	}
	*/
	
	private let url = "https://books.google.com/ngrams/interactive_chart?content=113100%2C113110&year_start=1960&year_end=2017&corpus=15&smoothing=3"
	
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
		Data.append(dvaldata)
		return end.upperBound
	}
	
	
	private var content = ""
	public func loadData() {
		Data = []
		if let url = URL(string: url ) {
			do {
				content = try String(contentsOf: url)
				//print(content)
				
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
