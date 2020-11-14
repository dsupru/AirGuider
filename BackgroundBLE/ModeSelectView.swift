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
    @State var show_airport_view : Bool = false
    var body: some View {
        if show_selection == false {
            if show_airport_view {
                AirPortView(bleManager: myBLEManager)
            } else {
                PlaneView(bleManager: myBLEManager)
            }
        } else {
                VStack {
                    Text("Choose Operations Mode")
                        .baselineOffset(15)
                        .bold()
                        .accentColor(.blue)
                        
                    Image("airport")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture(perform: {
                            myBLEManager.peripheralManagerIsOn = true
                            show_selection = false
                            show_airport_view = true
                        })
                        .padding(.all)
                    Image("airplane")
                        .resizable()
                        .scaledToFit()
                        .onTapGesture(perform: {
                            myBLEManager.centralManagerIsOn = true
                            show_selection = false
                        })
                        .padding(.all, 56.0)
                    
                }
        }
    }
}

struct ModeSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectView()
    }
}
