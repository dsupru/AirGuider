//
//  ConnectionToPeripheralDelegate.swift
//  BackgroundBLE
//
//  Created by D S on 8/18/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import Foundation
import CoreBluetooth

class ConnectionToPeripheral : NSObject, CBPeripheralDelegate, ObservableObject {
    var rxDataCharacteristic : CBCharacteristic?
    var myServicesUUID = CBUUID()
    var myCharacteristicsUUID = CBUUID()
    @Published var receivedASCIIData = NSString()
    @Published var directions : Dictionary<String, String> = [
        "Coordinates":"",
        "Runway Letter": "Unassigned"
    ]
    
    init(service: CBUUID, characteristic: CBUUID) {
        self.myServicesUUID = service
        self.myCharacteristicsUUID = characteristic
    }
    
    /*
    Invoked when you discover the peripheral’s available services.
    This method is invoked when your app calls the discoverServices(_:) method. If the services of the peripheral are successfully discovered, you can access them through the peripheral’s services property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
    */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
    
        guard let services = peripheral.services else {
            return
        }
        
        //Used to discover all the
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
        print("Discovered Services: \(services)")
    }
    
    /*
    Invoked when you discover the characteristics of a specified service.
    This method is invoked when your app calls the discoverCharacteristics(_:for:) method. If the characteristics of the specified service are successfully discovered, you can access them through the service's characteristics property. If successful, the error parameter is nil. If unsuccessful, the error parameter returns the cause of the failure.
    */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic, always right in our case
            if characteristic.uuid.isEqual(myCharacteristicsUUID)  {
                self.rxDataCharacteristic = characteristic
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxDataCharacteristic!)
                // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                // didUpdateNotificationStateForCharacteristic method will be called automatically
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            // To add write capability, add another characteristic
//            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
//                txCharacteristic = characteristic
//                print("Tx Characteristic: \(characteristic.uuid)")
//            }
            peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    // This method is called when characteristic is update (because we subscribed to it)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic == self.rxDataCharacteristic,
            let characteristicValue = characteristic.value,
            let ASCIIstring = NSString(data: characteristicValue,
                                       encoding: String.Encoding.utf8.rawValue)
            else { return }
        
        receivedASCIIData = ASCIIstring
        let recStr = receivedASCIIData as String
        let items = recStr.components(separatedBy: ":")
        if items.contains("Runway") {
            self.directions["Runway Letter"] = items[1]
            print(self.directions)
        } else if items.contains("Coordinates") {
            self.directions["Coordinates"] = items[1]
        }
        print("Value Received: \((receivedASCIIData as String))")
    }
    
    // Tells the delegate that the peripheral found descriptors for a characteristic.
    // This method is invoked when the app calls the discoverDescriptors()
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("*******************************************************")
        
        if error != nil {
            print("\(error.debugDescription)")
            return
        }
        guard let descriptors = characteristic.descriptors else { return }
            
        descriptors.forEach { descript in
            print("function name: DidDiscoverDescriptorForChar \(String(describing: descript.description))")
            // Need to have another characteristic to enable tx. Omitted because it is trivial
            print("Rx Value \(String(describing: self.rxDataCharacteristic?.value))")
            //print("Tx Value \(String(describing: txCharacteristic?.value))")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("+++++")
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did write val for characteristic")
    }
    
}
