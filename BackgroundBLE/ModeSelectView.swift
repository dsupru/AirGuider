//
//  ModeSelectView.swift
//  BackgroundBLE
//
//  Created by D S on 8/17/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import SwiftUI
import CoreBluetooth

enum BLEMode {
    case central
    case peripheral
}

struct ModeSelectView: View {
    @ObservedObject private var myBLEManager: BLEModel = BLEModel()
    //@State var centralSinkData = receivedASCIIData as String
    @State var message : String = "Data Delivered"
    var body: some View {
        VStack {
            Text("List Of Discovered Peripherals")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            List(myBLEManager.peripherals, id:\.self) { peripheral in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Name: \(peripheral.name)")
                        Text("Unique ID: \(peripheral.identifier)")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                    }
                    Spacer()
                    Text("connect")
                        .multilineTextAlignment(.trailing)
                        .onTapGesture {
                            self.myBLEManager.connect(peripheral)
//                            update connection
                    }
                }
            }
            Text(self.message)
                .onTapGesture {
                    self.message = self.myBLEManager.connPeripheralDelegate.receivedASCIIData as String
            }
                
            Group {
                HStack {
                    Toggle(isOn: $myBLEManager.peripheralManagerIsOn) {
                        Text("Peripheral Mode")
                    }
                }
                HStack {
                    Toggle(isOn: $myBLEManager.centralManagerIsOn) {
                        Text("Central Mode")
                        
                    }
                }
            }
            .padding(.bottom)
            
        }
        .padding(.horizontal)
    }
}

struct ModeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectView()
    }
}
