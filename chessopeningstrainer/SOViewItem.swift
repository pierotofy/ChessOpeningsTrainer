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
    var onTrainOpening: ((Opening) -> Void)?
    var multiple: Bool
    
    var body: some View{
        VStack{
            HStack{
                Button(action: {
                    if (onExploreOpening != nil){
                        onExploreOpening!(opening)
                    }
                }){
                    Text("Explore").frame(minHeight: 36)
                    Image(systemName: "magnifyingglass")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding(.trailing, 8)
                
                Button(action: {
                    if (onTrainOpening != nil){
                        onTrainOpening!(opening)
                    }
                }){
                    Text("Train").frame(minHeight: 36)
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, !multiple ? 32 : 0)
            
            if opening.descr != nil {
                DescriptionView(pgn: opening.pgn)
            }else{
                if !multiple {
                    Text(opening.name)
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, !multiple ? 32 : 0)
                }
                Text(opening.pgn)
                    .font(.subheadline)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, !multiple ? 32 : 0)
                    
            }
        }
    
    }
}

struct SOViewItem_Previews: PreviewProvider{
    static var previews: some View{
        SOViewItem(opening: Opening(name: "test", uci: "e2e4", pgn: "1. e4", rank: 20), multiple: false)
    }
}
