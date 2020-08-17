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
    var PeripheralManager: CBPeripheralManager!
    var CentralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    
    
    init() {
        self.PeripheralManager = CBPeripheralManager(delegate: nil, queue: nil)
        self.CentralManager = CBCentralManager(delegate: nil, queue: nil)
    }
    
    func peripheralMode() {
        
    }
    
}
