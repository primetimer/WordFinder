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
	
	func clean() {
		var n = data.count-1
		while n > 0 {
			if data[n].search == "" {
				data.remove(at: n)
			}
			n = n - 1
		}
		if data.count == 0 {
			appendSearch(search: "Example")
		}
	}
		
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
	func move(from : Int, to: Int)
	{
		let src = data[from]
		data.remove(at: from)
		data.insert(src, at: to)
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
			return model.data.count
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
			searcheditmap[model.data[indexPath.row]] = cell.uisearch
			cell.uisearch.delegate = self
			let searchstr = model.GetSearchString(row: indexPath.row)
			cell.SetSearchString(str: searchstr)
			return cell
		}
		return UITableViewCell()
	}
	//Map from textfields to row
	var searcheditmap : [NgramData:UITextField] = [:]
	
	private let chartcellid = "chartcellid"
	private var chartcelltemp : ChartCell? = nil
	private func GetChartCell(indexPath : IndexPath) -> UITableViewCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: chartcellid, for: indexPath) as? ChartCell
		{
			chartcelltemp = cell
			cell.ShowData(model: model)
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
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 && indexPath.row < model.data.count - 1 {
			return true
		}
		return false
	}
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if indexPath.section == 0 {
			if model.data[indexPath.row].search == "" {
				return .insert
			}
			return .delete
		}
		return .none
	}
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			model.data.remove(at: indexPath.row)
		case .insert:
			model.appendSearch(search: "")
		case .none:
			return
		}
		tv.reloadData()
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 0 {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		model.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
		tv.reloadData()
		/*
		let movedObject = self.fruits[sourceIndexPath.row]
		fruits.remove(at: sourceIndexPath.row)
		fruits.insert(movedObject, at: destinationIndexPath.row)
		NSLog("%@", "\(sourceIndexPath.row) => \(destinationIndexPath.row) \(fruits)")
		self.tableView.reloadData()
		*/
	}
	
	func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if sourceIndexPath.section != 0 {
			return sourceIndexPath
		}
		if proposedDestinationIndexPath.section != 0 {
			return sourceIndexPath
		}
		return proposedDestinationIndexPath
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
		tv.isEditing = false
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
		tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		//tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		tv.bottomAnchor.constraint(equalTo: myToolbar.topAnchor).isActive = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		setupAutoLayout()
	}
	override func viewDidAppear(_ animated: Bool) {
		tv.reloadData()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private var myToolbar: UIToolbar!
	private var noButton: UIBarButtonItem!
	private var refreshButton: UIBarButtonItem!
	private var editButton : UIBarButtonItem!
	
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
		
		//Navigation Bar
		navigationItem.title = "Word usage in print media"
		editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editAction));
		navigationItem.setRightBarButton(editButton, animated: false)
	}
	
	@objc func editAction() {
		tv.isEditing = !tv.isEditing
		model.clean()
		if tv.isEditing {
			model.appendSearch(search: "")
			editButton.title = "Done"
		} else {
			model.clean()
			editButton.title = "Edit"
		}
		tv.reloadData()
	}
	
	
	@objc func refreshButtonAction() {
		let count = model.data.count
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		print("TextField did begin editing method called")
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		for (index,data) in model.data.enumerated()  {
			if searcheditmap[data] == textField {
				model.refreshSearch(search: textField.text!, row: index)
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

