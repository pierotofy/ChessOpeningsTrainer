//
//  OpeningSelectionItem.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/26/21.
//


import SwiftUI

struct OpeningSelectionItem: View{
    var parent: OpeningSelectionView
    var opening: Opening
    
    var body: some View{
        
        if opening.descr != nil{
            Button(action: {
                parent.descrPgn = opening.pgn
            }){
                Text(opening.rankString())
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.caption, design: .monospaced))
                
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        
        }
        else {
            Button(action: {
                // Nothing
            }){
                Text(opening.rankString())
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.caption, design: .monospaced))
            }
            .buttonStyle(.borderedProminent)
            .tint(.gray)
        }
    }
}
