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
}

