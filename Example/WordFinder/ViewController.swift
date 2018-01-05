//
//  ViewController.swift
//  WordFinder
//
//  Created by primetimer on 01/04/2018.
//  Copyright (c) 2018 primetimer. All rights reserved.
//

import UIKit
import WordFinder
import Charts

class NgramModel {
	private lazy var loader = NGramLoader()
	var data : [NgramData] = []
	
	func appendSearch(search : String) {
		if let loaddata = loader.LoadData(search: search) {
			data.append(loaddata)
		}
	}
}

class ViewController: UIViewController {
	
	let uichart = LineChartView()
	let model = NgramModel()
	let showabsolute = false

	private func ShowData() {
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
	
	override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(uichart)
		LayoutUI()
		model.appendSearch(search: "Hello")
		model.appendSearch(search: "Hallo")
		model.appendSearch(search: "Goodbye")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		LayoutUI()
		ShowData()
	}
	
	func LayoutUI() {
		let w = view.frame.width
		let h = view.frame.height
		uichart.frame = CGRect(x: 0.0, y: 0.0, width: w, height: h)
		uichart.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		uichart.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		uichart.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
		uichart.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		uichart.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	

}

