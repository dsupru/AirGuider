//
//  BLEController.swift
//  BackgroundBLE
//
//  Created by D S on 8/16/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

// Global because the View doesn't update

struct PeripheralDescr: Hashable {
    static func == (lhs: PeripheralDescr, rhs: PeripheralDescr) -> Bool {
        return lhs.peripheral == rhs.peripheral
    }
    
    var name : String
    let services : [CBUUID]
    var peripheral : CBPeripheral
}

class BLEModel : NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, ObservableObject {
    
    var peripheralManager: CBPeripheralManager!
    var myServiceUUID: CBUUID
    var myCharacteristicUUID: CBUUID
    
    var myService: CBMutableService
    var myCharacteristic: CBMutableCharacteristic
    var centralManagerIsOn: Bool {
        get {
            return self.centralManager?.isScanning == true
        }
        set (togglePress){
            if togglePress == true {
                self.startScan()
            } else {
                self.cancelScan()
            }
        }
    }
    var peripheralManagerIsOn: Bool {
        get {
            return self.peripheralManager?.isAdvertising == true
        }
        set (togglePress){
            if togglePress == true {
                self.startAdvertising()
            } else {
                self.stopAdvertising()
            }
        }
    }
    override init() {
        
        self.myServiceUUID = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
        self.myCharacteristicUUID = CBUUID(string: "523D0E52-01CE-4AA7-A525-E99AC9FE2AC6")
        
        self.myCharacteristic = CBMutableCharacteristic(type: self.myCharacteristicUUID, properties: [.notify, .read], value: nil, permissions: [.readable])
        
        self.myService = CBMutableService(type: self.myServiceUUID, primary: true)
        self.myService.characteristics = [self.myCharacteristic]
        
        super.init()

        // configure central mode
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        // configure peripheral mode
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        print("initiated all variables")
    }
    
    func startScan() {
        self.peripherals = []
        if self.peripheralManager?.isAdvertising == true {
            self.stopAdvertising()
        }
        // start scanning for all devices
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:false])
        print("started the scan")
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            self.cancelScan()
        }
        // TODO add a timer
    }
    
    func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case CBManagerState.poweredOn:
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
        
        self.peripherals.append(peripheral)
        print("Found new pheripheral devices with services")
        print("Peripheral name: \(String(describing: peripheral.name))")
        print("**********************************")
        print ("Advertisement Data : \(advertisementData)")
    }
    func startAdvertising() {
        // TODO see if first need to stop cental mode
        if self.centralManager?.isScanning == true {
            self.cancelScan();
        }
        if self.peripheralManager?.isAdvertising == true {
            return;
        } else {
            self.peripheralManager?.startAdvertising([CBAdvertisementDataLocalNameKey: "BLEFromIOS",
                                                      CBAdvertisementDataServiceUUIDsKey: [self.myServiceUUID]])
            print("start advertising")
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
        if (peripheral.state == CBManagerState.poweredOn) {
            print("Peripheral on")
            // in case the service has already been added
            self.peripheralManager?.removeAllServices()
            
            self.peripheralManager?.add(self.myService)

        } else {
            print("peripheral is connected")
        }
    }
    
    
}
