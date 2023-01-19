import XCTest
@testable import BLEServices

final class BLEServicesManagerTests: XCTestCase {
    var dummyBLEServicesDelegate: DummyBLEServicesDelegate! // swiftlint:disable:this weak_delegate
    var mockCentralManagerFactory: CentralManagerFactory!
    var bleServicesManager: BLEServicesManager!

    override func setUp() {
        dummyBLEServicesDelegate = DummyBLEServicesDelegate()
        mockCentralManagerFactory = CentralManagerFactory(shouldMakeAMock: true)
        bleServicesManager = BLEServicesManager(withDelegate: dummyBLEServicesDelegate, resultQueue: .main, centralManagerFactory: mockCentralManagerFactory)
    }


    override func tearDown() {
        dummyBLEServicesDelegate = nil
        mockCentralManagerFactory = nil
        bleServicesManager = nil
    }


    func test_InitialState_IsUndetermined() {
        bleServicesManager.start()

        XCTAssertEqual(bleServicesManager.currentState, .nonDetermined)
    }


    func test_startScanning_setsStateToScanning() {
        bleServicesManager.start()

        bleServicesManager.startScanning()
        XCTAssertEqual(bleServicesManager.currentState, .scanning)
    }


    func test_stopScanning_setsStateToPoweredOn() {
        bleServicesManager.start()

        bleServicesManager.startScanning()
        XCTAssertEqual(bleServicesManager.currentState, .scanning)

        bleServicesManager.stopScanning()
        XCTAssertEqual(bleServicesManager.currentState, .poweredOn)
    }
}
