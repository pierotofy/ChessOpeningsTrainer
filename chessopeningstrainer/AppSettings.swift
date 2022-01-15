//
//  UserPrefs.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/18/21.
//

import SwiftUI


public class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("color") var color: String = "white"
    @AppStorage("maxTreeMoves") var maxTreeMoves: Int = 7
    @AppStorage("ttStartingPosition") var ttStartingPosition: String = ""
    @AppStorage("isPro") var isPro: Bool = false
}

