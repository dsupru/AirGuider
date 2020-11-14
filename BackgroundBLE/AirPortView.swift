//
//  AirPortView.swift
//  BackgroundBLE
//
//  Created by D S on 11/13/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct AirPortView: View {
    @ObservedObject private var myBLEManager: BLEModel
    @State var message : String = "A5:B6:R3 -- A:1N:7"
    @State var planeSelected : CBCentral?
    var planes : [String] = ["Boeing 767", "Antonov An-158",
    "Airbus A350", "Airbus A330"]
    @State var centralToNameDictionary :Dictionary<CBCentral, String> = [:]
    init(bleManager : BLEModel) {
        self.myBLEManager = bleManager
        self.message = ""
    }
    var body: some View {
        VStack {
            Text("List Of Active Airplanes")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            List(self.myBLEManager.subscribedCentrals, id:\.self) { central in
                let plane_name = planes.randomElement()!
                VStack {
                    HStack {
                        Image("small-airplane")
                            .resizable()
                            .frame(width: 50.0, height: 50.0)
                            .scaledToFit()
                            .padding(.all)
                        Text("\(plane_name)")
                        Text("Unique ID: \(central.identifier)")
                            .font(.footnote)
                            .foregroundColor(Color.red)
                    }
                    .onTapGesture {
                        planeSelected = central
                    }
                    Spacer()
                }
            }
            HStack {
                Text("Plane selected: ----> \(planeSelected?.identifier.description ?? "NONE") ")
            }
            .padding(.bottom, 10.0)
            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            Spacer()
            Text("Directives")
                .bold()
                .padding(.bottom, 5.0)
            Text("Proceed to Runway A")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, -1.0)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    let cafe = "Runway:A".data(using: .ascii)
                    myBLEManager.peripheralManager.updateValue(cafe!, for: myBLEManager.myCharacteristic, onSubscribedCentrals: [planeSelected!])
                })
            Text("Proceed to Runway B")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, -1.0)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    let cafe = "Runway:B".data(using: .ascii)
                    myBLEManager.peripheralManager.updateValue(cafe!, for: myBLEManager.myCharacteristic, onSubscribedCentrals: [planeSelected!])
                })
            Text("Proceed to Runway C")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, -1.0)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    let cafe = "Runway:C".data(using: .ascii)
                    myBLEManager.peripheralManager.updateValue(cafe!, for: myBLEManager.myCharacteristic, onSubscribedCentrals: [planeSelected!])
                })
            Text("Set Coordinates to ATG7-E1WG-YJN2")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, -1.0)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    let cafe = "Coordinates:ATG7-E1WG-YJN2".data(using: .ascii)
                    myBLEManager.peripheralManager.updateValue(cafe!, for: myBLEManager.myCharacteristic, onSubscribedCentrals: [planeSelected!])
                })
            Text("Set Coordinates to BQG3-456G-YNM2")
                .font(.headline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.vertical, +1.0)
                .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                    let cafe = "Coordinates:BQG3-456G-YNM2".data(using: .ascii)
                    myBLEManager.peripheralManager.updateValue(cafe!, for: myBLEManager.myCharacteristic, onSubscribedCentrals: [planeSelected!])
                })

        }
    }
}

struct AirPortView_Previews: PreviewProvider {
    static var previews: some View {
        AirPortView(bleManager: BLEModel())
    }
}
