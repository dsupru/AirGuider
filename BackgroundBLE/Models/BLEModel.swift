//
//  BLEController.swift
//  BackgroundBLE
//
//  Created by D S on 8/16/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEModel : NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if (peripheral.state == CBManagerState.poweredOn) {
            print("Peripheral on")
            //self.startAdvertising()
        } else {
            print("peripheral is connected")
        }
    }
    
    
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    var peripheralManager: CBPeripheralManager!
    var myUUID: CBUUID
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
        
        // configure peripheral mode
        self.myUUID = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
        self.myCharacteristic = CBMutableCharacteristic(type: self.myUUID, properties: [.notify, .read], value: nil, permissions: [.readable])
        
        self.myService = CBMutableService(type: self.myUUID, primary: true)
        self.myService.characteristics = [self.myCharacteristic]
        self.peripheralManager?.add(self.myService)
        
    }
    
    func startScan() {
        self.peripherals = []
        // start scanning for all devices
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
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
            print("Bluetooth is powered on")
        case CBManagerState.unauthorized:
            print("Unauthorized for BLE")
        case CBManagerState.poweredOff:
            print("Powered Off from central manager")
        default:
            print("other error encountered")
        }
    }
    
    func startAdvertising() {
        // TODO see if first need to stop cental mode
        if self.centralManager?.isScanning == true {
            self.cancelScan();
        }
    }
    
}
