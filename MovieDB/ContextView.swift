//
//  ContextView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 10/4/21.
//

import Foundation
import SwiftUI


//https://developer.apple.com/forums/thread/122440

struct ContextView: View {
    @EnvironmentObject var user: UserData
    
    @State var context: AnyView

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    
    @State var qty = 0
    
    var body: some View {
        
        VStack
        {
            context
            
        }
        .onAppear(perform: {getCartQtyData()})

        
        .navigationBarHidden(true)
        
        .background(
            HStack {
                NavigationLink(destination: MainView(), isActive: $HomeActive) {EmptyView()}
                NavigationLink(destination: SearchView(), isActive: $SearchActive) {EmptyView()}
                NavigationLink(destination: UserView(), isActive: $UserActive) {EmptyView()}
                NavigationLink(destination: OrderView(), isActive: $OrderActive) {EmptyView()}
                NavigationLink(destination: CartView(), isActive: $CartActive) {EmptyView()}
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
            }
        )
        
        .toolbar {
          ToolbarItemGroup(placement: .bottomBar) {
            HStack{
                Button(action: {
                    self.HomeActive = true
                })
                {
                    Image(systemName: "house").imageScale(.large)
                }
                Button(action: {
                    self.SearchActive = true
                })
                {
                    Image(systemName: "magnifyingglass").imageScale(.large)
                }
                
                Button(action: {
                    self.UserActive = true
                })
                {
                    Image(systemName: "person.crop.circle").imageScale(.large)
                }
                
                Button(action: {
                    self.OrderActive = true
                })
                {
                    Image(systemName: "shippingbox").imageScale(.large)
                }
                
                Button(action: {
                    self.CartActive = true

                })
                {
                    
                 ZStack {
                     Image(systemName: "cart").imageScale(.large)
                     
                     if(self.qty > 0) {
                         Text("\(self.qty)")
                             .foregroundColor(Color.black)
                             .background(Capsule().fill(Color.orange).frame(width:30, height:20))
                             .offset(x:20, y:-10)
                         
                     }

                    }
                }
             }
          }
        }

    }
    
    func getCartQtyData() {
        API(user: user).getCartQty(){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    self.qty = qty
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
