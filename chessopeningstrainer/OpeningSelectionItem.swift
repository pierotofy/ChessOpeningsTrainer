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
                if let rank = opening.rank {
                    Text(rank.toString())
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(.caption, design: .monospaced))
                }else{
                    Image(systemName: "info.circle")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        
        }
        else if let rank = opening.rank {
            Button(action: {
                // Nothing
            }){
                Text(rank.toString())
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.caption, design: .monospaced))
            }
            .buttonStyle(.borderedProminent)
            .tint(.gray)
        }
    }
}
