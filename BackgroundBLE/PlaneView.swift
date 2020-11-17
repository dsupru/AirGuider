//
//  PlaneView.swift
//  BackgroundBLE
//
//  Created by D S on 11/13/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import SwiftUI

struct PlaneView: View {
    @ObservedObject private var myBLEManager: BLEModel
    @ObservedObject var connManager : ConnectionToPeripheral
    init(bleManager : BLEModel) {
        self.myBLEManager = bleManager
        self.connManager = bleManager.connPeripheralDelegate
    }
    var body : some View {
        VStack {
            // enter ATC where we are connected
            List(self.myBLEManager.peripherals, id:\.self) { peripheral in
                VStack {
                    HStack {
                        Image("small-airport")
                            .resizable()
                            .frame(width: 50.0, height: 50.0)
                            .scaledToFit()
                            .padding(.all)
                        VStack {
                            Text("Name: \(peripheral.name)")
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.yellow)
                            Text("Unique ID: \(peripheral.identifier)")
                                .font(.footnote)
                                .foregroundColor(Color.red)
                        }
                        Spacer()
                        if self.myBLEManager.connectedPeripherals.contains(
                            peripheral) {
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
            }
            .frame(height: 150.0)
            Image(self.connManager.directions["Runway Letter"] ?? "Unnasigned")
                .resizable()
                .scaledToFit()
            Spacer()
   
            VStack(alignment: .leading, spacing: 0.0) {
                HStack {
                    Text("Coordinates:")
                    Text(self.connManager.directions["Coordinates"] ?? "Unnasigned")
                }
                HStack {
                    Text("Runway Letter:")
                        .multilineTextAlignment(.leading)
                        .padding(.vertical)
                    Text(self.connManager.directions["Runway Letter"] ?? "B")
                }
            }
            
        }
    }
}


struct PlaneView_Previews: PreviewProvider {
    static var previews: some View {
        PlaneView(bleManager: BLEModel())
    }
}
