//
//  MainView.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 1/1/22.
//

import Foundation
import SwiftUI

struct MainView: View{

    
    init(){

    }
    
    var body: some View{
        TabView{
            BoardTreeView(color: AppSettings.shared.color)
                .tabItem{
                    Image(systemName: "checkerboard.rectangle")
                    Text("Board")
                }
            OpeningSelectionView()
                .tabItem{
                    Image(systemName: "list.bullet.indent")
                    Text("List")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider{
    static var previews: some View{
        MainView()
    }
}
