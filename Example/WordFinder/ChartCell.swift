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

class ExpandableCell : UITableViewCell {
	private var _expanded = true
	
	var expanded : Bool {
		set { _expanded = newValue }
		get { return _expanded }
	}
}

class ChartParamCell : UITableViewCell {
	static let chartparamcellid = "chartparamcellid"
	var uiabsolutelabel = UILabel()
	var uiabsolute = UISwitch()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		contentView.addSubview(uiabsolute)
		contentView.addSubview(uiabsolutelabel)
		let w = self.frame.width - 20.0
		uiabsolutelabel.frame = CGRect(x: 20.0, y: 4.0, width : w,height: 24.0)
		uiabsolutelabel.text = "Abolute Values:"
		uiabsolute.frame = CGRect(x: w-40.0 , y: 0, width: 40.0, height: 24.0)
		uiabsolute.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
		uiabsolute.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
		uiabsolute.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class ChartCell : UITableViewCell {
	static let chartcellid = "chartcellid"
	var uichart = LineChartView()
	var showabsolute = false
	
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
			let smooth = d.SmoothValues(smoothing: 5)
			let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			hue = hue + dhue
			var lineChartEntry = [ChartDataEntry]()
			var lineChartSmoothEntry = [ChartDataEntry]()
			for i in 0..<d.data.count {
				let yval = showabsolute ? d.data[i].absolue : d.data[i].relative*100.0
				let value = ChartDataEntry(x: Double(d.data[i].year), y: yval)
				lineChartEntry.append(value)
				let ysmooth = smooth[i].relative*100.0
				let smoothvalue =  ChartDataEntry(x: Double(d.data[i].year), y: ysmooth)
				lineChartSmoothEntry.append(smoothvalue)
			}
			let line = LineChartDataSet(values: lineChartEntry, label: d.search)
			let linesmmooth = LineChartDataSet(values: lineChartSmoothEntry, label: "")
			line.lineWidth = 1.0
			line.setColor(color)
			line.drawCirclesEnabled = false
			
			linesmmooth.lineWidth = 3.0
			linesmmooth.setColor(color)
			linesmmooth.drawCirclesEnabled = false
			
			alldata.addDataSet(line)
			alldata.addDataSet(linesmmooth)
		}
		uichart.leftAxis.labelPosition = .insideChart
		uichart.rightAxis.enabled = false
		uichart.xAxis.labelPosition = .bottom
		uichart.xAxis.enabled = true
		uichart.data = alldata
	}
}
