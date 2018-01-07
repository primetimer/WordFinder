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



class ViewController: UIViewController ,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	private let inputsection = 0
	private let chartsection = 1
	private let chartrow = 0
	private let chartparamrow = 1
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case inputsection:
			return model.data.count
		case chartsection:
			return 2
		default:
			assert(false)
			return 0
		}
	}

	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let width = tableView.frame.size.width
		switch indexPath.section {
		case inputsection:
			return 40.0
		case chartsection:
			switch indexPath.row {
			case chartrow:
				return width
			case chartparamrow:
				if NgramParam.shared.graphexpanded {
						return ChartParamCell.expandedheight
				}
				return ChartParamCell.shrinkedheight

			default:
				assert(false)
			}

		default:
			return 40.0
		}
	}

	
	private var inputcelltemp : InputCell? = nil
	private func GetInputCell(indexPath : IndexPath) -> UITableViewCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: InputCell.inputcellid, for: indexPath) as? InputCell
		{
			inputcelltemp = cell
			//searcheditmap[model.data[indexPath.row]] = cell.uisearch
			cell.uisearch.delegate = self
			//let searchstr = model.GetSearchString(row: indexPath.row)
			cell.uisearch.setData(data: model.data[indexPath.row])
			//cell.SetSearchString(str: searchstr)
			return cell
		}
		return UITableViewCell()
	}
	//Map from textfields to row
	//var searcheditmap : [NgramData:UITextField] = [:]
	private var chartcelltemp : ChartCell? = nil
	private func GetChartCell(indexPath : IndexPath) -> UITableViewCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: ChartCell.chartcellid, for: indexPath) as? ChartCell
		{
			chartcelltemp = cell
			cell.ShowData(model: model)
			return cell
		}
		return UITableViewCell()
	}
	private var chartcellparamtemp : ChartParamCell? = nil
	private func GetChartParamCell(indexPath : IndexPath) -> ChartParamCell {
		if let cell = tv.dequeueReusableCell(withIdentifier: ChartParamCell.chartparamcellid, for: indexPath) as? ChartParamCell
		{
			chartcellparamtemp = cell
			cell.uiabsolute.addTarget(self, action: #selector(paramAction), for: .valueChanged)
			cell.uismooth.addTarget(self, action: #selector(paramAction), for: .valueChanged)
			cell.uidelta.addTarget(self, action: #selector(paramAction), for: .valueChanged)
			return cell
		}
		return ChartParamCell()
	}
	@objc func paramAction() {
		if let absolute = chartcellparamtemp?.uiabsolute.isOn {
			NgramParam.shared.absolute = absolute
		}
		if let delta = chartcellparamtemp?.uidelta.selectedSegmentIndex {
			NgramParam.shared.delta = delta
		}
		if let index = chartcellparamtemp?.uismooth.selectedSegmentIndex {
			NgramParam.shared.smoothing = index
		}
		chartcelltemp?.ShowData(model: model)
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case inputsection:
			return "Search Terms"
		case chartsection:
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
		case inputsection:
			return GetInputCell(indexPath: indexPath)
		case chartsection:
			switch(row) {
			case chartrow:
				return GetChartCell(indexPath: indexPath)
			case chartparamrow:
				let cell = GetChartParamCell(indexPath: indexPath)
				return cell
			default:
				assert(false)
				break
			}
			
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
			_ = model.appendSearch(search: "")
		case .none:
			return
		}
		tv.reloadData()
	}
	
	func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == inputsection {
			return true
		}
		return false
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		model.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
		tv.reloadData()
	}
	
	func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if sourceIndexPath.section != inputsection {
			return sourceIndexPath
		}
		if proposedDestinationIndexPath.section != inputsection {
			return sourceIndexPath
		}
		return proposedDestinationIndexPath
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? ChartParamCell {
			
			NgramParam.shared.graphexpanded = !NgramParam.shared.graphexpanded
			cell.SetHidden(hidden: !NgramParam.shared.graphexpanded)
			tableView.beginUpdates()
			tableView.endUpdates()
		}
	}
	
	lazy var tv: MyTableView = {
		let tv = MyTableView(frame: .zero, style: .plain)
		tv.delegate = self
		tv.dataSource = self
		return tv
	}()

	let model = NgramModel()
	override func viewDidLoad() {
		super.viewDidLoad()
		_ = model.appendSearch(search: "Hello")
		_ = model.appendSearch(search: "Goodbye")
		self.view.addSubview(tv)
		CreateToolBar()
		setupAutoLayout()
	}
	
	private func setupAutoLayout() {
		tv.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		tv.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
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
	private var doneButton : UIBarButtonItem!
	
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
		doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editAction));
		navigationItem.setRightBarButton(editButton, animated: false)
	}
	
	@objc func editAction() {
		tv.isEditing = !tv.isEditing
		model.cleanup()
		if tv.isEditing {
			_ = model.appendSearch(search: "")
			navigationItem.setRightBarButton(doneButton, animated: false)
		} else {
			model.cleanup()
			navigationItem.setRightBarButton(editButton, animated: false)
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
		/*
		var found = false
		
		for (index,data) in model.data.enumerated()  {
			if searcheditmap[data] == textField {
				model.refreshSearch(search: textField.text!, row: index)
				found = true
			}
		}
		assert(found == true)
		*/
		guard let inputfield = textField as? InputField else { assert(false) }
		guard let data = inputfield.data else { assert(false)  }
		guard let input = inputfield.text else { assert(false) }
		if let newdata = model.refeshSearch(search: input, data: data) {
			inputfield.data = newdata
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

