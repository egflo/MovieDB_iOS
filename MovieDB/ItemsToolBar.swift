//
//  ItemsToolBar.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 10/9/21.
//

import Foundation
import SwiftUI

struct ItemsToolbar: View {
    @EnvironmentObject var user: UserData

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false

    var body: some View {
          if(user.showToolBar) {
              HStack{
                  Button(action: {
                      self.HomeActive = true
                  })
                  {
                      NavigationLink(destination: MainView(), isActive: $HomeActive) {
                          Image(systemName: "house").imageScale(.large)
                      }

                  }
                  //Spacer()

                  Button(action: {
                      self.SearchActive = true
                  })
                  {
                      NavigationLink(destination: SearchView(), isActive: $SearchActive) {
                          Image(systemName: "magnifyingglass").imageScale(.large)
                      }
                  }
                  //Spacer()

                  Button(action: {
                      self.UserActive = true
                  })
                  {
                      NavigationLink(destination: UserView(), isActive: $UserActive) {
                          Image(systemName: "person.crop.circle").imageScale(.large)
                      }
                  }
                  //Spacer()

                  Button(action: {
                      self.OrderActive = true
                  })
                  {
                      NavigationLink(destination: OrderView(), isActive: $OrderActive) {
                          Image(systemName: "shippingbox").imageScale(.large)
                      }
                  }
                  //Spacer()

                  Button(action: {
                      self.CartActive = true

                  })
                  {
                      
                   ZStack {
                       NavigationLink(destination: CartView(), isActive: $CartActive) {
                           Image(systemName: "cart").imageScale(.large)

                           if(user.qty > 0) {
                               
                               Text("\(user.qty)")
                                   .foregroundColor(Color.black)
                                   .background(Capsule().fill(Color.orange).frame(width:30, height:20))
                                   .offset(x:-5, y:-10)
                           }

                       }
                    }
                }
            }
              .onAppear(perform: {self.getCartQtyData()})
        }
    }
    
    

    
    func getCartQtyData() {
        let URL = "\(MyVariables.API_IP)/cart/qty/"

        NetworkManager.shared.getRequest(of: Int.self, url: URL){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    user.qty = qty
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    user.qty = 0
                    print(error.localizedDescription)
                }
            }
        }
    }
}
