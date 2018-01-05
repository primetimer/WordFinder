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

	private func ShowData() {
		uichart.chartDescription?.text = "My awesome chart"
		for d in model.data {
			var lineChartEntry = [ChartDataEntry]()
			
			
			
			for i in 0..<d.data.count {
				let value = ChartDataEntry(x: Double(d.data[i].year), y: d.data[i].relative)
				print(d.data[i],d.data[i].relative)
				lineChartEntry.append(value)
			}
			let line = LineChartDataSet(values: lineChartEntry, label: d.search)
			let data = LineChartData()
			data.addDataSet(line)
			uichart.data = data
		}
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		view.addSubview(uichart)
		LayoutUI()
		model.appendSearch(search: "Hello")
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

