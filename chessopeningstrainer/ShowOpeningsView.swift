//
//  DescriptionWebView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import SwiftUI

struct ShowOpeningsView: View {
    var openings: [Opening]
    
    var body: some View{
        Text("Hello")
    }
}

struct ShowOpeningsView_Previews: PreviewProvider{
    static var previews: some View{
        ShowOpeningsView(openings: [Opening(name: "test", uci: "e2e4", pgn: "1. e4", rank: 20)])
    }
}
