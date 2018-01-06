//
//  InputCell.swift
//  WordFinder_Example
//
//  Created by Stephan Jancar on 05.01.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import WordFinder

class InputCell : UITableViewCell  {
	var uisearch = UITextField()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(uisearch)
		uisearch.frame = CGRect(x: 10.0, y: 0, width: self.frame.width, height: self.frame.height)
		uisearch.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		uisearch.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		uisearch.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func SetSearchString(str : String) {
		uisearch.text = str
	}
	
	
}






