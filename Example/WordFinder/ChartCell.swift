//
//  ChartCell.swift
//  WordFinder_Example
//
//  Created by Stephan Jancar on 05.01.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Charts
import WordFinder

class ChartCell : UITableViewCell {
	var uichart = LineChartView()
	private let showabsolute = false
	
	override var frame : CGRect {
		get { return super.frame }
		set {
			super.frame = newValue
			uichart.frame = CGRect(x: 0 , y:0 , width: newValue.width, height: newValue.height)
		}
	}
	
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(uichart)
		uichart.frame = CGRect(x: 0.0, y: 0, width: self.frame.width, height: self.frame.height)
		uichart.backgroundColor = .white
		uichart.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
		uichart.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		uichart.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func ShowData(model : NgramModel) {
		uichart.chartDescription?.text = "Ngram chart"
		let alldata = LineChartData()
		let dhue : CGFloat = 1.0 / CGFloat(model.data.count)
		var hue : CGFloat = 0.0
		for d in model.data {
			let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			hue = hue + dhue
			var lineChartEntry = [ChartDataEntry]()
			for i in 0..<d.data.count {
				let yval = showabsolute ? d.data[i].absolue : d.data[i].relative*100.0
				let value = ChartDataEntry(x: Double(d.data[i].year), y: yval)
				print(d.data[i],d.data[i].relative)
				lineChartEntry.append(value)
			}
			let line = LineChartDataSet(values: lineChartEntry, label: d.search)
			line.lineWidth = 5.0
			line.setColor(color)
			line.drawCirclesEnabled = false
			alldata.addDataSet(line)
		}
		uichart.leftAxis.labelPosition = .insideChart
		uichart.rightAxis.enabled = false
		uichart.xAxis.labelPosition = .bottom
		uichart.xAxis.enabled = true
		uichart.data = alldata
	}
}
