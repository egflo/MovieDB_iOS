//
//  CheckoutView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 6/20/21.
//

import SwiftUI
import Stripe
import UIKit
import CoreData
import URLImage
import SDWebImageSwiftUI
import Combine
import AlertToast

//https://github.com/stripe-samples/accept-a-payment/blob/main/custom-payment-flow/client/ios-swiftui/AcceptAPayment/Views/Card.swift#L22


struct StripePaymentCardTextField: UIViewRepresentable {
    
    @Binding var cardParams: STPPaymentMethodCardParams
    @Binding var isValid: Bool
    
    func makeUIView(context: Context) -> STPPaymentCardTextField {
        let input = STPPaymentCardTextField()
        input.borderWidth = 0
        input.delegate = context.coordinator
        return input
    }
    
    func makeCoordinator() -> StripePaymentCardTextField.Coordinator { Coordinator(self) }

    func updateUIView(_ view: STPPaymentCardTextField, context: Context) { }
    
    class Coordinator: NSObject, STPPaymentCardTextFieldDelegate {

        var parent: StripePaymentCardTextField
        
        init(_ textField: StripePaymentCardTextField) {
            parent = textField
        }
        
        func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
            parent.cardParams = textField.cardParams
            parent.isValid = textField.isValid
        }
    }
}


struct AddressChangeView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    @State private var selection: Address?
    @Binding var checkout: Checkout
    @State var addresses = [Address]()
    
    var body: some View {
        List(selection: $selection) {
            ForEach(self.checkout.addresses, id: \.id) { address in

                HStack {
                    if address == self.selection || address.id == checkout.defaultId{
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.blue)
                    }

                    VStack(alignment: .leading) {
                        Text("\(address.firstName) \(address.lastName)")
                        Text("\(address.address), \(address.city) \(address.state) \(address.postcode)")
                    }
           
                    Spacer()
                }
                .contentShape(Rectangle())
                .frame(height: 50)
                .onTapGesture {
                    self.selection = address
                    uploadAddressData(address: address)
                    //self.checkout.address = address
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Address Change")
        .onAppear(perform: {
            self.getAddressData()
        })
    }
    
    func getAddressData() {
        API(user: userData).getAddresses(){ (result) in
            switch result {
            case .success(let addreses):
                DispatchQueue.main.async {
                    self.addresses = addreses
                }
            case .failure(let error):
                viewModel.setError(title: "Error", subtitle: error.localizedDescription)
            }
        }
    }
    
    func uploadAddressData(address: Address) {
        API(user: userData).uploadCheckoutAddress(address: address){ (result) in
            switch result {
            case .success(let checkout):
                DispatchQueue.main.async {
                    self.checkout = checkout
                }
            case .failure(let error):
                viewModel.setError(title: "Error", subtitle: error.localizedDescription)
            }
        }
    }
}

//https://stackoverflow.com/questions/67681114/weird-error-when-using-stripe-stppaymenthandler-cred-store-error-25300

struct CheckoutContentView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State var isActive = false
    @State var isEnabled = true
    @State var checkout: Checkout
    
    let width = (UIScreen.main.bounds.width - 33)

    @State var validCard = false
    @State var card = STPPaymentMethodCardParams()
    
    @State var loading = false
    @State var PaymentActive = false
    @State var paymentIntentParams: STPPaymentIntentParams?
    @State var paymentMethodParams: STPPaymentMethodParams?
    @State var sale: Sale = Sale(id: 0, customerId: 0, saleDate: 0, salesTax: 0.00, subTotal: 0.00, total: 0.00, stripeId: "", orders: [Order](), shipping: nil)

    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if let paymentIntent = self.paymentIntentParams {
                    
                    Button(action: {
                        print("Pay")
                        self.loading = true
                        paymentIntent.paymentMethodParams = paymentMethodParams
                        //pay()
                        //uploadOrder()

                    }) {
                        HStack {
                            Text("Pay").bold()
                            
                            if(self.loading){
                                ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))

                            }
                        }
                        .frame(width: width, height: 50)
                        .foregroundColor(Color.white)
                        .background(isEnabled ? Color.blue: Color.gray)
                        .cornerRadius(8)
                        .disabled(loading)
                        .paymentConfirmationSheet(isConfirmingPayment: $loading,
                                                                             paymentIntentParams: paymentIntent,
                                                                             onCompletion: onCompletion)
                    }
                    .disabled(!isEnabled)

                    
                } else {
                    Text("Loading...")
                }
                
            }

            VStack(alignment: .leading) {
                
                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                    
                    Divider()
                    
                    VStack {
                        
            
                            VStack(alignment: .leading){
                                Text("Shipping Address").font(.headline).bold()
                                if let address = checkout.addresses.first(where: {$0.id == checkout.defaultId}) {
                                    NavigationLink(destination: AddressChangeView(checkout: $checkout), isActive: $isActive) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                // do something with foo
                                                 Text("\(address.firstName) \(address.lastName)")
                                                 if(address.unit.count > 0) {
                                                     Text(address.unit).font(.subheadline)
                                                 }
                                                 Text(address.address).font(.subheadline)
                                                 Text("\(address.city), \(address.state), \(address.postcode)").font(.subheadline)
                                                 Text("United States").font(.subheadline)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .font(Font.system(size: 30))
                                                .foregroundColor(Color.blue)

                                        }
                                        
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                } else {
                                   // item could not be found'
                                    HStack {
                                        Text("Add Address")
                                        Spacer()
                                        Image(systemName: "plus")
                                            .font(Font.system(size: 30))
                                            .foregroundColor(Color.blue)
                                    }
                                    .onTapGesture(perform: {
                                        
                                    })
                                    //.background(isEnabled = false)
                                }
                            }.contentShape(Rectangle())


                    }
                    Divider()
                        .padding(.bottom, 15)
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("Order Total(s)").font(.headline).bold()

                        Text("Shipping: \(formatCurrency(price: 0.00))")
                            .font(.subheadline).bold()
            
                        
                        Text("Subtotal: \(formatCurrency(price: checkout.subTotal))")
                            .font(.subheadline).bold()
            
                        
                        Text("Estimated Tax: \(formatCurrency(price: checkout.salesTax))")
                            .font(.subheadline).bold()
        
                        
                        Text("Total: \(formatCurrency(price: checkout.total))")
                            .font(.headline).bold()
                        
                    }
                    

                }
                else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                    
                    Divider()
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("Order Total(s)").font(.headline).bold()

                            Text("Shipping: \(formatCurrency(price: 0.00))")
                                .font(.subheadline).bold()
                
                            
                            Text("Subtotal: \(formatCurrency(price: checkout.subTotal))")
                                .font(.subheadline).bold()
                
                            
                            Text("Estimated Tax: \(formatCurrency(price: checkout.salesTax))")
                                .font(.subheadline).bold()
            
                            
                            Text("Total: \(formatCurrency(price: checkout.total))")
                                .font(.headline).bold()
                            
                        }
                        
                        Spacer()

                        
                        NavigationLink(destination: AddressChangeView(checkout: $checkout)) {
                            HStack {
            
                                VStack(alignment: .leading){
                                    Text("Shipping Address").font(.headline).bold()
                                    if let address = checkout.addresses.first(where: {$0.id == checkout.defaultId}) {
                                       // do something with foo
                                        Text("\(address.firstName) \(address.lastName)")
                                        if(address.unit.count > 0) {
                                            Text(address.unit).font(.subheadline)
                                        }
                                        Text(address.address).font(.subheadline)
                                        Text("\(address.city), \(address.state), \(address.postcode)").font(.subheadline)
                                        Text("United States").font(.subheadline)
                                        
                                    } else {
                                       // item could not be found
                                    }
                                
                                }
                                
                                
                                Image(systemName: "chevron.right")
                                    .font(Font.system(size: 30))
                                    .foregroundColor(Color.blue)

                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                    }

                    Divider()
                        .padding(.bottom, 5)

                }
                else if horizontalSizeClass == .regular && verticalSizeClass == .regular {

                    Divider()
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("Order Total(s)").font(.headline).bold()

                            Text("Shipping: \(formatCurrency(price: 0.00))")
                                .font(.subheadline).bold()
                
                            
                            Text("Subtotal: \(formatCurrency(price: checkout.subTotal))")
                                .font(.subheadline).bold()
                
                            
                            Text("Estimated Tax: \(formatCurrency(price: checkout.salesTax))")
                                .font(.subheadline).bold()
            
                            
                            Text("Total: \(formatCurrency(price: checkout.total))")
                                .font(.headline).bold()
                            
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: AddressChangeView(checkout: $checkout)) {
                            HStack {
            
                                VStack(alignment: .leading){
                                    Text("Shipping Address").font(.headline).bold()
                                    if let address = checkout.addresses.first(where: {$0.id == checkout.defaultId}) {
                                       // do something with foo
                                        Text("\(address.firstName) \(address.lastName)")
                                        if(address.unit.count > 0) {
                                            Text(address.unit).font(.subheadline)
                                        }
                                        Text(address.address).font(.subheadline)
                                        Text("\(address.city), \(address.state), \(address.postcode)").font(.subheadline)
                                        Text("United States").font(.subheadline)
                                        
                                    } else {
                                       // item could not be found
                                    }
                                
                                }
                                
                                
                                Image(systemName: "chevron.right")
                                    .font(Font.system(size: 30))
                                    .foregroundColor(Color.blue)

                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        
                    }

                    Divider()
                        .padding(.bottom, 5)

                }
                
            }
             .frame(width:width)
             .padding(.top, 10)
             .padding(.bottom, 10)
            
            VStack{
                //StripePaymentCardTextField(cardParams: $card, isValid: $validCard)
                STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams)
            }.frame(width: width, height: 50, alignment: .leading)

            ForEach(checkout.cart, id: \.id) { item in
                VStack {
                    let m = MovieDecode(movie: item.movie!)
                    
                    Divider().frame(width: width)

                    HStack {
                        VStack {
                            WebImage(url: URL(string: m.poster()))
                                    .resizable()
                                    .renderingMode(.original)
                                    .placeholder(Image("no_image"))
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(8)
                            
                        }.frame(width: 40, height: 70)
                        
                        VStack(alignment: .leading) {
                            
                            Text(m.title()).font(.headline)
                            Text("Qty: \(item.quantity)")
                                .font(.subheadline).bold()
                                .foregroundColor(.gray)

                        }
                        
                        Spacer()
                        Text("\(m.price())").font(Font.system(size: 20)).bold()
                        
                    }.frame(width: width)
                }
            }
            
            Divider().frame(width: width)
            
        }
        .background(
            HStack {
                NavigationLink(destination: OrderConfirmationView(sale: $sale), isActive: $PaymentActive) {EmptyView()}
            }
        )
        
        .onAppear(perform: {getPaymentIntent()})
        

        .toast(isPresenting: $loading){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(type: .loading, title: "Processing Order", subTitle: "Do not close the application.")

        }
        
    }
    
    func formatCurrency(price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        
        return formatter.string(from: NSNumber(value: price))!
    }
    
    //https://stripe.com/docs/payments/integration-builder?platform=ios
  
    func getPaymentIntent() {
        STPAPIClient.shared.publishableKey = MyVariables.STRIPE_PUBLIC_KEY

        API(user: user).preparePaymentIntent(amount: checkout.total, currency: "USD", description: "TEST IOS CHARGE") { (result) in
            switch result {
            case .success(let paymentIntent):
                DispatchQueue.main.async {
                    self.paymentIntentParams = paymentIntent
                }
            case .failure(let error):
                viewModel.setError(title: "Error", subtitle: error.localizedDescription)
            }
        }
    }
    
    func uploadOrder(order: ProcessOrder) {
        STPAPIClient.shared.publishableKey = MyVariables.STRIPE_PUBLIC_KEY

        API(user: user).uploadOrder(order: order) { (result) in
            switch result {
            case .success(let sale):
                DispatchQueue.main.async {
                    self.sale = sale
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    func onCompletion(status: STPPaymentHandlerActionStatus, pi: STPPaymentIntent?, error: NSError?) {
        if status == .succeeded {
            if let address = checkout.addresses.first(where: {$0.id == checkout.defaultId}) {
               // do something with foo
                let order = ProcessOrder(total: checkout.total, subtotal: checkout.subTotal, salesTax: checkout.salesTax, cart: checkout.cart, address: address, customerId: user.id, stripeId: paymentIntentParams!.stripeId!)
                uploadOrder(order: order)
                self.PaymentActive = true
                
            } else {
               // item could not be found
                print("Should not be here. Address should be set already")
            }
            
        }
        
        if status == .failed {
            guard let error_status = error else {
                
                viewModel.setError(title: "Error", subtitle: "Error Processing Payment")
                return

            }
            viewModel.setError(title: "Error", subtitle: error_status.localizedDescription)

        }
    }
    
}


//https://github.com/stripe/stripe-ios/issues/1204
 //https://stripe.com/docs/payments/accept-a-payment
struct CheckoutView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State var checkout:Checkout?
    
    var body: some View {
        
        VStack {
            
            if let checkout = checkout {
                
                CheckoutContentView(checkout: checkout)

            }
            
            else {
                ProgressView()
            }
            
        }
        .onAppear(perform: {getCheckoutData()})
        .navigationBarTitle(Text("Checkout"), displayMode: .large)
    }
    
    func getCheckoutData() {
        API(user: user).getCheckout() { (result) in
            switch result {
            case .success(let checkout):
                DispatchQueue.main.async {
                    self.checkout = checkout
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)

                }
                
            }
        }
    }
}


struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}




