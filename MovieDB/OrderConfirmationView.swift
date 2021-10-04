//
//  OrderConfirmationView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 6/23/21.
//

import SwiftUI

struct OrderConfirmationView: View {
    @Binding var sale: Sale
    @EnvironmentObject var user: UserData
    //@State var sale = SaleDetails(sale: nil, card: nil)
    
    let width = (UIScreen.main.bounds.width - 33)

    @State var HomeActive = false ;
    
    var body: some View {

        
        ScrollView {
            Image(systemName: "checkmark")
                .resizable()
                .scaledToFill()
                .frame(width: 100.0, height: 100.0) // as per your requirement
                .foregroundColor(Color.green)
            
            Text("Order Placed!").font(.title).bold()
                .padding(.bottom, 2)
            
            Text("Order#\(String(sale.id))")
                .font(.subheadline).bold()
                .padding(.bottom, 5)
            
           // Text("You have been charged \(calc_total()) to your \(paymentData.network) ending \(paymentData.last4)")
            Text("You have been charged \(formatCurrency(price: sale.total))")
                .font(.subheadline).bold()
                .padding(.bottom, 5)

            //Link("Your Receipt", destination: URL(string: paymentData.receipt_url)!)
             //   .padding(.bottom, 15)
            
            
            Button(action: {
                print("Continue Shopping")
                self.HomeActive = true
            }) {
                Text("Continue Shopping").bold()
                    //.frame(width: 200 , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
            }
            .frame(width: width, height: 50)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
            
        }.offset(y: 25 )
        
        .navigationBarHidden(true)
        
        .background(
            HStack {
                NavigationLink(destination: MainView(), isActive: $HomeActive) {EmptyView()}
            }
        )
         
    }
    
    func formatCurrency(price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: price))!
    }

}

