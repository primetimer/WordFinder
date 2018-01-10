import UIKit
import XCTest
import WordFinder
@testable import WordFinder_Example

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	/*
	func testTenReuqests {
		let loader = NGramLoader()
		for nr in 1...10 {
			if let data = loader.LoadData(search: String(nr)) {
				print(nr,data.data[0])
				if data.data.count == 0 {
					print(nr)
				}
			} else {
				print("First Error at :",nr)
				break
			}
		}
	}
	*/
		
	
	func testNotFound() {
		let model = NgramModel()
		_ = model.appendSearch(search: "Nonne mit")
		XCTAssert(model.data.count == 1)
		XCTAssert(model.data[0].data.count == 0)
		_ = model.appendSearch(search: "Nonne mit", corpus: .german)
		XCTAssert(model.data.count == 2)
		XCTAssert(model.data[1].data.count > 0)
		XCTAssert(model.data[1].data[5].relative == 1.7035773680618149e-08)
		
	}
	
	func testContinuations() {
		let loader = NGramLoader()
		let cont = loader.LoadContinuations(search: "University of")
		XCTAssert(cont.count==11)
		XCTAssert(cont[8] == "University of Texas")
	}
	
	func testComplex() {
		let model = NgramModel()
		_ = model.appendSearch(search: "((Bigfoot + Sasquatch) - (Loch Ness monster + Nessie))")
		let count = model.data.count
		XCTAssert(count == 1)
		for d in model.data[0].data {
			if d.year == 1900 {
				let testval = d.relative
				print(testval)
				XCTAssert(testval == -0.00000011632606261580136)
			}
		}
	}
	
    func testExample() {
		let model = NgramModel()
		model.appendSearch(search: "yes")
		model.appendSearch(search: "no")
		model.appendSearch(search: "")
		let count = model.data.count
		XCTAssert(count == 3)
		XCTAssert(model.data[0].data.count > 100)
		XCTAssert(model.data[1].data.count > 100)
		model.cleanup()

        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
