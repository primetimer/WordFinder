//
//  Extensions.swift
//  WordFinder_Example
//
//  Created by Stephan Jancar on 07.01.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class MyTableView : UITableView {
	
	override init(frame: CGRect, style: UITableViewStyle) {
		super.init(frame: frame, style: style)
		self.translatesAutoresizingMaskIntoConstraints = false
		self.backgroundColor = .lightGray
		self.register(WordTableViewHeader.self, forHeaderFooterViewReuseIdentifier: WordTableViewHeader.headerId)
		self.register(InputCell.self, forCellReuseIdentifier: InputCell.inputcellid)
		self.register(ChartCell.self, forCellReuseIdentifier: ChartCell.chartcellid)
		self.register(ChartParamCell.self, forCellReuseIdentifier: ChartParamCell.chartparamcellid)
		self.isEditing = false
		self.delaysContentTouches = false
		self.canCancelContentTouches = true
		self.estimatedRowHeight = 44.0
		self.rowHeight = UITableViewAutomaticDimension
	}
	
	override func touchesShouldCancel(in view: UIView) -> Bool {
		if view is UITextField {
			return true
		}
		return super.touchesShouldCancel(in: view)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
