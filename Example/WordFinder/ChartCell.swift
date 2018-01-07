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

class ChartParamCell : UITableViewCell {
	let x0 : CGFloat = 20.0
	let y0 : CGFloat = 4.0
	let dy : CGFloat = 30.0
	
	static let shrinkedheight : CGFloat = 30.0
	static let expandedheight : CGFloat = 4*30.0 + 15.0

	static let chartparamcellid = "chartparamcellid"
	private var uiabsolutelabel = UILabel()
	private var uismoothlabel = UILabel()
	private var uideltalabel = UILabel()
	var uititle = UILabel()
	var uiabsolute = UISwitch()
	var uismooth = UISegmentedControl(items: ["0","1","2","3","4","5"])
	var uidelta = UISegmentedControl(items: ["none","delta"])
	
	func SetHidden(hidden : Bool) {
		for s in contentView.subviews {
			if s != uititle {
				s.isHidden = hidden
			}
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.accessoryType = .disclosureIndicator
		
		contentView.addSubview(uititle)
		contentView.addSubview(uiabsolute)
		contentView.addSubview(uiabsolutelabel)
		contentView.addSubview(uismooth)
		contentView.addSubview(uismoothlabel)
		contentView.addSubview(uidelta)
		contentView.addSubview(uideltalabel)

		let w = contentView.frame.width
		do {
			uititle.text = "Parameters:"
			uititle.frame = CGRect(x: x0, y: y0, width : w,height: dy)
		}
		do {
			uiabsolutelabel.text = "Abolute Values:"
			uiabsolutelabel.frame = CGRect(x: x0, y: y0+dy, width : w,height: dy)
			uiabsolute.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
			uiabsolute.isOn = NgramParam.shared.absolute
			let size = uiabsolute.sizeThatFits(.zero)
			uiabsolute.frame = CGRect(x: w-size.width-2*x0 , y: y0+dy, width: size.width, height: size.height)
			
		}
		do {
			uismoothlabel.text = "Smoothing:"
			uismoothlabel.frame = CGRect(x: x0, y: y0+2*dy, width : w,height: dy)
			uismooth.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
			uismooth.autoresizingMask = .flexibleLeftMargin
			uismooth.selectedSegmentIndex = NgramParam.shared.smoothing
			let size = uismooth.sizeThatFits(.zero)
			let rect = CGRect(x: w - size.width - 2*x0, y: y0 + 2*dy, width: size.width,height :size.height)
			uismooth.frame = rect
		}
		do {
			uideltalabel.text = "Show:"
			uideltalabel.frame = CGRect(x: x0, y: y0+3*dy, width : w,height: dy)
			uidelta.transform = CGAffineTransform(scaleX: 0.75, y: 0.75);
			uidelta.autoresizingMask = .flexibleLeftMargin
			uidelta.selectedSegmentIndex = 0
			let size = uidelta.sizeThatFits(.zero)
			let rect = CGRect(x: w - size.width - 2*x0, y: y0 + 3*dy, width: size.width,height :size.height)
			uidelta.frame = rect
		}
		SetHidden(hidden: !NgramParam.shared.graphexpanded)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class ChartCell : UITableViewCell {
	static let chartcellid = "chartcellid"
	var uichart = LineChartView()
	
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
			let smooth = d.SmoothValues(smoothing: NgramParam.shared.smoothing)
			let delta = d.DeltaValues()
			let color = UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
			hue = hue + dhue
			
			var lineChartEntry = [ChartDataEntry]()
			var lineChartSmoothEntry = [ChartDataEntry]()
			for i in 0..<d.data.count {
				var yval = 0.0
				if NgramParam.shared.delta == 1 {
					yval = delta[i].relative
				} else
				{
					yval = NgramParam.shared.absolute ? d.data[i].absolue : d.data[i].relative*100.0
				}
				let value = ChartDataEntry(x: Double(d.data[i].year), y: yval)
				lineChartEntry.append(value)
				
				if NgramParam.shared.delta ==
					0 {
					let ysmooth = smooth[i].relative*100.0
					let smoothvalue =  ChartDataEntry(x: Double(d.data[i].year), y: ysmooth)
					lineChartSmoothEntry.append(smoothvalue)
				}
			}
			let line = LineChartDataSet(values: lineChartEntry, label: d.search)
			let linesmmooth = LineChartDataSet(values: lineChartSmoothEntry, label: nil)
			line.lineWidth = 1.0
			line.setColor(color)
			line.drawCirclesEnabled = false
			line.form = .none
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
