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
    @State var message : String = "Data ="
    @State var show_selection : Bool = true
    @State var show_central_view : Bool = false
    @State var show_peripheral_view : Bool = false
    var body: some View {
        if show_selection == false {
            if show_central_view {
                CentralView(bleManager: myBLEManager)
            } else {
                PeripheralView()
            }
        } else {
            Group {
                HStack {
                    Toggle("Peripheral Mode", isOn: $myBLEManager.peripheralManagerIsOn)
                        .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                            show_selection = false
                        })
                    }
                    HStack {
                        Toggle(isOn: $myBLEManager.centralManagerIsOn) {
                            Text("Central Mode")
                                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                                    show_selection = false
                                    show_central_view = true
                                })
                        }
                    }
                }
                .padding(.bottom)
                
            }
        }
        
        
    }

struct ModeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectView()
    }
}

struct CentralView: View {
    @ObservedObject private var myBLEManager: BLEModel
    @State var message : String = "A5:B6:R3 -- A:1N:7"
    
    init(bleManager : BLEModel) {
        self.myBLEManager = bleManager
        self.message = ""
    }
    var body: some View {
        VStack {
            Text("List Of Airplanes")
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
                    if self.myBLEManager.connectedPeripheralID.contains(
                        peripheral.identifier) {
                        Text("Connected")
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    } else {
                        Text("connect")
                            .multilineTextAlignment(.trailing)
                            .onTapGesture {
                                self.myBLEManager.connect(peripheral)
    //                            update connection
                        }
                    }
                    
                }
            }
            Text(self.message)
                .onTapGesture {
                    self.message = self.myBLEManager.connPeripheralDelegate.receivedASCIIData as String
                }
                .padding(.horizontal)
        }
        VStack {
            Text("Directives to Send")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    // send to all devices we are connected to
                    for a_peripheral in self.myBLEManager.peripherals {
                        if self.myBLEManager.connectedPeripheralID.contains(
                            a_peripheral.identifier) {
                            let cafe = "directive".data(using: .ascii)
                            a_peripheral.peripheral.writeValue(cafe!, for: myBLEManager.myCharacteristic, type: .withResponse)
                        }
                    }
                })
            Text("Directives to Send")
            Text("Directives to Send")
            Text("Directives to Send")
            Text("Directives to Send")
        }
    }
}
    
struct PeripheralView: View {
    var body : some View {
        Text("hello")
    }
}
