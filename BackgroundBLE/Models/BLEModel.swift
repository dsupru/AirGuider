//
//  BLEController.swift
//  BackgroundBLE
//
//  Created by D S on 8/16/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEModel {
    
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    var peripheralManager: CBPeripheralManager!
    var myUUID: CBUUID
    var myService: CBMutableService
    var myCharacteristic: CBMutableCharacteristic
    
    init() {
        // configure central mode
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
        
        // configure peripheral mode
        self.myUUID = CBUUID(string: "71DA3FD1-7E10-41C1-B16F-4430B506CDE7")
        self.myCharacteristic = CBMutableCharacteristic(type: self.myUUID, properties: [.notify, .read], value: nil, permissions: [.readable])
        
        self.myService = CBMutableService(type: self.myUUID, primary: true)
        self.myService.characteristics = [self.myCharacteristic]
        self.peripheralManager.add(self.myService)
        
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
    
    func startAdvertising() {
        // TODO see if first need to stop cental mode
        if self.centralManager?.isScanning == true {
            self.cancelScan();
        }
    }
    
}
