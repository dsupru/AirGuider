//
//  BLEController for BackgroundBLE project
//
//  Owns and handles BLE communications and events.
//
//  Created by D S on 8/16/20.
//

import Foundation
import CoreBluetooth
import UIKit
// structure to pas additional information about Peripheral into View
struct PeripheralDescr: Hashable {
    // using identifier as it should be unique
    static func == (lhs: PeripheralDescr, rhs: PeripheralDescr) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    var name : String
    let services : [CBUUID]
    let identifier : UUID
    var peripheral : CBPeripheral
}

class BLEModel : NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, ObservableObject {
    var planes : [String] = ["Boeing 767", "Antonov An-158",
    "Airbus A350", "Airbus A330"]
    @Published var plane_name : String
    var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    var centralManager: CBCentralManager! = nil
    var peripheralManager: CBPeripheralManager! = nil
    @Published var connPeripheralDelegate : ConnectionToPeripheral
    // array of peripheral scanned in central mode
    @Published var peripherals : [PeripheralDescr] = []
    @Published var connectedPeripherals : [PeripheralDescr] = []
    @Published var subscribedCentrals : [CBCentral] = []
    
    var myServiceUUID: CBUUID
    var myCharacteristicUUID: CBUUID
    
    var myService: CBMutableService
    var myCharacteristic: CBMutableCharacteristic
    var centralManagerIsOn: Bool {
        get {
            if self.centralManager != nil {
                return true
            } else {
                return false
            }
        }
        set (toggleCentral){
            if toggleCentral == true {
                self.centralManager = CBCentralManager(delegate: self, queue: nil)
            } else {
                //
                if self.centralManager.isScanning == true { self.cancelScan() }
                self.centralManager = nil
            }
        }
    }
    var peripheralManagerIsOn: Bool {
        get {
            if self.peripheralManager != nil {
                return true
            } else {
                return false
            }
        }
        set (togglePress){
            if togglePress == true {
                self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
                //self.startAdvertising()
            } else {
                if self.peripheralManager.isAdvertising == true { self.stopAdvertising() }
                // destroys peripheral object
                // will implicitly call Cancel connection on Central
                self.peripheralManager = nil
            }
        }
    }
    
    override init() {
        
        self.myServiceUUID = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
        self.myCharacteristicUUID = CBUUID(string: "523D0E52-01CE-4AA7-A525-E99AC9FE2AC6")
        
        self.myCharacteristic = CBMutableCharacteristic(type: self.myCharacteristicUUID, properties: [.notify, .read, .write, .indicate, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        
        self.myService = CBMutableService(type: self.myServiceUUID, primary: true)
        self.myService.characteristics = [self.myCharacteristic]
        self.connPeripheralDelegate = ConnectionToPeripheral(service: myServiceUUID, characteristic: myCharacteristicUUID)
        self.plane_name = planes.randomElement()!
        super.init()

    }
    
    func startScan() {
        peripherals = []
        // start scanning for all devices
        // to scan in the background, need to specify serviceUUID
        centralManager?.scanForPeripherals(withServices: [self.myServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        print("started the scan")
    }
    
    func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
 // MARK: -- Handlers for Central BLE Events
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case CBManagerState.poweredOn:
                self.startScan()
                print("central is powered on")
            case CBManagerState.unauthorized:
                print("Unauthorized for BLE")
            case CBManagerState.poweredOff:
                print("Powered Off from central manager")
            default:
                print("other error encountered")
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print ("Detected")
        // get either the peripheral name or the name it is advertising
        let name : String = utilGetName(peripheral, advertisementData)
        let uuids : [CBUUID] = utilUUIDsOrDefault(advertisementData)
        let newPerDescription = PeripheralDescr(name: name, services: uuids, identifier: peripheral.identifier, peripheral: peripheral )
        if self.peripherals.contains(newPerDescription) == false {
            peripherals.append(newPerDescription)
        }
        
        print("Found new pheripheral devices with services")
        print("Peripheral name: \(String(describing: peripheral.identifier))")
        print("RSSI   : \(RSSI)")
        print("**********************************")
        print ("Advertisement Data : \(advertisementData)")
    }
    
    // Called from UI on tap
    func connect(_ peripheral: PeripheralDescr) {
        self.centralManager?.connect(peripheral.peripheral, options: nil)
        self.connectedPeripherals.append(peripheral)
    }
    
    // Called when connection was successfull
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("*****************************")
        print("Connection complete")
        print("Peripheral info: \(String(describing: peripheral))")
        
        //Stop Scan- We don't need to scan once we've connected to a peripheral.
        centralManager?.stopScan()
        print("Scan Stopped")
        
        //Discovery callback
        peripheral.delegate = connPeripheralDelegate
        //Only look for services that matches transmit uuid
        peripheral.discoverServices([self.myServiceUUID])
        
    }
    // MARK: -- Handlers for Peripheral Events
    func startAdvertising() {

        if self.peripheralManager?.isAdvertising == true {
            return;
        } else {
            self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: "BLEFromIOS",
                                                      CBAdvertisementDataServiceUUIDsKey: [self.myServiceUUID]])
        }
    }
    
    func stopAdvertising() {
        self.peripheralManager?.stopAdvertising()
        print("peripheral stopped advertising")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print(error as Any)
        } else {
            print ("started advertising")
        }
    }
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral on")
            // in case the service has already been added
            self.peripheralManager?.removeAllServices()
            self.peripheralManager?.add(self.myService)
            self.startAdvertising()
        case .poweredOff:
            print("Peripheral off")
        case .unauthorized:
            print("Bluetooth permissions missing")
        default:
            print("Peripheral in unsupported mode")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central : CBCentral, didSubscribeTo characteristic : CBCharacteristic) {
        print("Central substcribed to characteristic \(characteristic)")
        print("\(central.identifier)")
        self.subscribedCentrals.append(central)
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if (error != nil) {
            print("Error changing notification state:\(String(describing: error?.localizedDescription))")
            
        } else {
            print("Characteristic's value subscribed")
        }
        
        if (characteristic.isNotifying) {
            print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
        }
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral")
    }
    func scheduleUpdates() {
        let cafe = "hello".data(using: .ascii)
        _ = peripheralManager.updateValue(cafe!, for: self.myCharacteristic, onSubscribedCentrals: nil)
    }
}

