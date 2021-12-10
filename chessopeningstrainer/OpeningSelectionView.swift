//
//  GameSelectionView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 12/8/21.
//

import Foundation
import SwiftUI

struct OpeningSelectionView: View{
    @State private var searchText = ""
    
    let openings: [Opening] = [.sicilian]
    
    var body: some View{
        NavigationView{
           List(openings, children: \.variations) { o in
                   Image(systemName: "checkerboard.shield")
                   Text(o.name)
                   Button(action: {
                       print(o.name)
                   }){
                       Image(systemName: "arrowtriangle.right.circle.fill")
                   }
                   .buttonStyle(.borderedProminent)
                   .tint(.green)
                   .frame(maxWidth: .infinity, alignment: .trailing)
                   .padding(.trailing, 10)
               
           }
           
           .searchable(text: $searchText)
                .navigationBarHidden(true)
        }
    }
}

struct OpeningSelectionScene_Previews: PreviewProvider{
    static var previews: some View{
        OpeningSelectionView()
.previewInterfaceOrientation(.portrait)
    }
}
