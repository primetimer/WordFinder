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

class InputField : UITextField {
	var row : Int = 0
}

class InputCell : UITableViewCell  {
	var uisearch = InputField()
	var uicorpus = UIButton()
	
	//static let inputcellid = "inputcellid"
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		uicorpus.setTitle("Language", for: .normal)
		uicorpus.setTitle("Language", for: .selected)
		uicorpus.layer.borderWidth = 1.0
		uicorpus.setTitleColor(.black, for: .normal)
		uicorpus.titleLabel?.font = uicorpus.titleLabel?.font.withSize(10.0)

		contentView.addSubview(uisearch)
		contentView.addSubview(uicorpus)
		bringSubview(toFront: uicorpus)
		let corpussize = uicorpus.sizeThatFits(.zero)
	
		uisearch.frame = CGRect(x: 10.0, y: 0, width: self.frame.width-corpussize.width-20.0 , height: self.frame.height)
		let w = contentView.frame.width
		let h = contentView.frame.height
		uicorpus.frame = CGRect(x: w-corpussize.width-40.0, y: 20.0, width: corpussize.width, height:  20.0)
		uicorpus.isHidden = false

	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func SetData(row: Int,data : NgramData) {
		uisearch.row = row
		uisearch.text = data.search
		uicorpus.setTitle(data.corpus.str, for: .normal)
	}
}






