//
//  DescriptionWebView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import SwiftUI

struct OpsList : Identifiable{
    let id = UUID()
    
    var opening: Opening
    var items: [OpsList]?
}

struct ShowOpeningsView: View {
    var openings: [Opening]
    
    func opsList() -> [OpsList]{
        return openings.map { OpsList( opening: $0, items: [OpsList(opening: $0)] )}
    }
    
    var body: some View{
        if (openings.count == 1){
            SOViewItem(opening: openings[0])
        }else{
            List(opsList(), children: \.items){ ol in
                if ol.items != nil{
                    Text(ol.opening.name)
                }else{
                    SOViewItem(opening: ol.opening)
                }
            }
        }
    }
}

struct ShowOpeningsView_Previews: PreviewProvider{
    static var previews: some View{
        ShowOpeningsView(openings: [Opening(name: "test", uci: "e2e4", pgn: "1. e4", rank: 20), Opening(name: "test2", uci: "d2d4", pgn: "1. d4", rank: 22)])
    }
}
