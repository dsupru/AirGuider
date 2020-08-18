//
//  UtilityFunctions.swift
//  BackgroundBLE
//
//  Created by D S on 8/18/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

func utilGetName(_ peripheral: CBPeripheral, _ advertisementData: [String : Any]) -> String {
    let name : String? = peripheral.name
    if name == nil {
        return utilAdvertisedNameOrDefault(advertisementData)
    } else {
        return name!;
    }
}
func utilAdvertisedNameOrDefault(_ advertisementData: [String : Any]) -> String {
    guard let name: String = advertisementData["kCBAdvDataLocalName"] as? String else {return "Undefined"}
    return name
}

func utilUUIDsOrDefault(_ advertisementData: [String : Any]) -> [CBUUID] {
    guard let uuids: [CBUUID] = advertisementData["kCBAdvDataServiceUUIDs"] as? [CBUUID] else {return [] }
    return uuids
}

