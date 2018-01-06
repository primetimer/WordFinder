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
	func refreshSearch(search : String, row : Int) {
		if let loaddata = loader.LoadData(search: search) {
			data[row] = loaddata
		}
	}
		
	func GetSearchString(row : Int) -> String {
		if row >= data.count { return "" }
		let ans = data[row].search
		return ans
	}
}

class ViewController: UIViewController ,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let width = tableView.frame.size.width
		switch indexPath.section {
		case 0:
			return 40.0
		case 1:
			return width
		default:
			return 40.0
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 3
		case 1:
			return 1
		default:
			assert(false)
			return 0
		}
	}
	
	private let inputcellid = "inputcellid"
	private var inputcelltemp : InputCell? = nil
	private func GetInputCell(indexPath : IndexPath) -> UITableViewCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: inputcellid, for: indexPath) as? InputCell
		{
			inputcelltemp = cell
			searcheditmap[indexPath.row] = cell.uisearch
			cell.uisearch.delegate = self
			let searchstr = model.GetSearchString(row: indexPath.row)
			cell.SetSearchString(str: searchstr)
			return cell
		}
		return UITableViewCell()
	}
	//Map from textfields to row
	var searcheditmap : [Int:UITextField] = [:]
	
	private let chartcellid = "chartcellid"
	private var chartcelltemp : ChartCell? = nil
	private func GetChartCell(indexPath : IndexPath) -> UITableViewCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: chartcellid, for: indexPath) as? ChartCell
		{
			chartcelltemp = cell
			chartcelltemp?.ShowData(model: model)
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Search Terms"
		case 1:
			return "Chart"
		default:
			return nil
		}
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = indexPath.section
		let row = indexPath.row
		switch(section)
		{
		case 0:
			return GetInputCell(indexPath: indexPath)
		case 1:
			return GetChartCell(indexPath: indexPath)
		default:
			assert(false)
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: WordTableViewHeader.headerId) as! WordTableViewHeader
		return header
	}
	
	lazy var tv: UITableView = {
		let tv = UITableView(frame: .zero, style: .plain)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.backgroundColor = .lightGray
		tv.delegate = self
		tv.dataSource = self
		tv.register(WordTableViewHeader.self, forHeaderFooterViewReuseIdentifier: WordTableViewHeader.headerId)
		tv.register(InputCell.self, forCellReuseIdentifier: self.inputcellid)
		tv.register(ChartCell.self, forCellReuseIdentifier: self.chartcellid)
		
		return tv
	}()

	let model = NgramModel()
	override func viewDidLoad() {
		super.viewDidLoad()
		model.appendSearch(search: "Hello")
		model.appendSearch(search: "Hallo")
		model.appendSearch(search: "Goodbye")
		self.view.addSubview(tv)
		CreateToolBar()
		setupAutoLayout()
		
	}
	
	private func setupAutoLayout() {
		//let w = view.frame.width
		//let h = view.frame.height
		tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		//tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tv.bottomAnchor.constraint(equalTo: myToolbar.topAnchor).isActive = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		setupAutoLayout()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private var myToolbar: UIToolbar!
	private var noButton: UIBarButtonItem!
	private var refreshButton: UIBarButtonItem!
	private func CreateToolBar() {
		// make uitoolbar instance
		let w = self.view.frame.width
		let frame = CGRect(x: 0, y: self.view.bounds.height - 44.0, width: w, height: 40.0)
		myToolbar = UIToolbar(frame: frame)
		
		// set the position of the toolbar
		myToolbar.layer.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height-20.0)
		myToolbar.barStyle = .blackTranslucent
		myToolbar.tintColor = .white
		myToolbar.backgroundColor = .black
		
		// make a button
		noButton = UIBarButtonItem(title: "", style:.plain, target: self, action: nil)
		let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
		refreshButton = UIBarButtonItem(title: "Refresh", style:.plain, target: self, action: #selector(refreshButtonAction))
		
		// add the buttons on the toolbar
		myToolbar.items = [noButton, flexibleButton,refreshButton]
		
		// add the toolbar to the view.
		self.view.addSubview(myToolbar)
	}
	
	@objc func refreshButtonAction() {
		let count = model.data.count
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		print("TextField did begin editing method called")
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		for i in 0..<100  {
			if searcheditmap[i] == textField {
				model.refreshSearch(search: textField.text!, row: i)
			}
		}
		if chartcelltemp != nil {
			chartcelltemp?.ShowData(model: model)
		}
		print("TextField did end editing method called")
	}
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		print("TextField should begin editing method called")
		return true;
	}
	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		print("TextField should clear method called")
		return true;
	}
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		print("TextField should snd editing method called")
		return true;
	}
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		print("While entering the characters this method gets called")
		return true;
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		print("TextField should return method called")
		textField.resignFirstResponder();
		self.becomeFirstResponder()
		return true;
	}
	
}

