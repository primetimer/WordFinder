//
//  NgramTableView.swift
//  WordFinder_Example
//
//  Created by Stephan Jancar on 05.01.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Charts
import WordFinder

class WordTableViewHeader: UITableViewHeaderFooterView {
	
	static let headerId = "WordHeaderId"
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

