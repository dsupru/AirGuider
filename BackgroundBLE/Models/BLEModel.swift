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
    var peripheralManager: CBPeripheralManager!
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    
    init() {
        self.peripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        self.centralManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
    func cancelScan() {
        self.centralManager?.stopScan()
        print("Scan Stopped")
        print("Number of Peripherals Found: \(peripherals.count)")
    }
    
    func peripheralMode() {
        
    }
    
}
