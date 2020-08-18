//
//  ModeSelectView.swift
//  BackgroundBLE
//
//  Created by D S on 8/17/20.
//  Copyright © 2020 Supr. Inc. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct ModeSelectView: View {
    @ObservedObject private var myBLEManager: BLEModel = BLEModel()
    
    var body: some View {
        VStack {
            List(myBLEManager.peripherals, id:\.self) { peripheral in
                Text("\(peripheral.name)")
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
