//
//  DescriptionWebView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/25/21.
//

import SwiftUI

struct SOViewItem: View {
    var opening: Opening
    var onExploreOpening: ((Opening) -> Void)?
    
    var body: some View{
        HStack{
            Button(action: {
                if (onExploreOpening != nil){
                    onExploreOpening!(opening)
                }
            }){
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.trailing, 10)
            
            Button(action: {}){
                
            }.buttonStyle(.borderedProminent)
        }
    
    }
}

struct SOViewItem_Previews: PreviewProvider{
    static var previews: some View{
        SOViewItem(opening: Opening(name: "test", uci: "e2e4", pgn: "1. e4", rank: 20))
    }
}
