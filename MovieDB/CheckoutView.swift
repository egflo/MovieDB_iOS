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


//https://stackoverflow.com/questions/67681114/weird-error-when-using-stripe-stppaymenthandler-cred-store-error-25300

struct iPhoneCheckOutView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    var checkout: Checkout
    
    let width = (UIScreen.main.bounds.width - 33)

    @State var validCard = false
    @State var card = STPPaymentMethodCardParams()
    
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    @State var PaymentActive = false


    @State var loading = false
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
                        .background(Color.blue)
                        .cornerRadius(8)
                        .disabled(loading)
                        .paymentConfirmationSheet(isConfirmingPayment: $loading,
                                                                             paymentIntentParams: paymentIntent,
                                                                             onCompletion: onCompletion)
                    }

                    
                } else {
                    Text("Loading...")
                }
                
            }

            VStack(alignment: .leading) {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Shipping Address").font(.headline).bold()
                        if(checkout.address.unit.count > 0) {
                            Text(checkout.address.unit).font(.subheadline)
                        }
                        Text(checkout.address.address).font(.subheadline)
                        Text("\(checkout.address.city), \(checkout.address.state), \(checkout.address.postcode)").font(.subheadline)
                        Text("United States").font(.subheadline)
                    }.padding(.bottom, 10)
                    
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        
                        Text("Subtotal: \(formatCurrency(price: checkout.subTotal))")
                            .font(.subheadline).bold()
            
                        
                        Text("Taxes: \(formatCurrency(price: checkout.salesTax))")
                            .font(.subheadline).bold()
        
                        
                        Text("Total: \(formatCurrency(price: checkout.total))")
                            .font(.headline).bold()
                        
                    }.padding(.bottom, 5)
                    
                    Spacer()
            
                }
                
            }
             .frame(width:width)
             .padding(.top, 10)
            
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
        .onAppear(perform: {getPaymentIntent()})
        

        .toast(isPresenting: $loading){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(type: .loading, title: "Processing Order", subTitle: "Do not close the application.")

        }
        
        .background(
            HStack {
                NavigationLink(destination: MainView(), isActive: $HomeActive) {EmptyView()}
                NavigationLink(destination: SearchView(), isActive: $SearchActive) {EmptyView()}
                NavigationLink(destination: UserView(), isActive: $UserActive) {EmptyView()}
                NavigationLink(destination: OrderView(), isActive: $OrderActive) {EmptyView()}
                NavigationLink(destination: CartView(), isActive: $CartActive) {EmptyView()}
                NavigationLink(destination: OrderConfirmationView(sale: $sale), isActive: $PaymentActive) {EmptyView()}
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
                print(error.localizedDescription)
            }
        }
    }
    
    func uploadOrder() {
        STPAPIClient.shared.publishableKey = MyVariables.STRIPE_PUBLIC_KEY

        API(user: user).uploadOrder(checkout: checkout, paymentIntent: paymentIntentParams!) { (result) in
            switch result {
            case .success(let sale):
                DispatchQueue.main.async {
                    self.sale = sale
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func onCompletion(status: STPPaymentHandlerActionStatus, pi: STPPaymentIntent?, error: NSError?) {

        // MARK: Demo cleanup
        if status == .succeeded {
            uploadOrder()
            self.PaymentActive = true
        }
        
        if status == .failed {
            guard let error_status = error else {
                
                viewModel.subtitle = "Error Processing Payment"
                return

            }
            viewModel.subtitle = error_status.localizedDescription
            viewModel.show = true
        }
    }
    
}


struct iPadCheckoutView: View {
    @EnvironmentObject var user: UserData

    @State var Address: String = ""
    @State var AddressStatus: Bool = false
    
    @State var Unit: String = ""
    @State var UnitStatus: Bool = false
    
    @State var City: String = ""
    @State var CityStatus: Bool = false
    
    @State var State: String = ""
    @State var StateStatus: Bool = false
    
    @State var PostCode: String = ""
    @State var PostCodeStatus: Bool = false
    
    let width = (UIScreen.main.bounds.width - 33)

    
    var body: some View {
        
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Shipping Address").font(.headline).bold()
                if(user.data.unit.count > 0) {
                    Text(user.data.unit).font(.subheadline).bold()
                }
                Text(user.data.address).font(.subheadline).bold()
                Text("\(user.data.city), \(user.data.state), \(user.data.postcode)").font(.subheadline).bold()
                Text("United States").font(.subheadline).bold()
            }
            
            Spacer()
            
        }
        
        /*
        Text("Billing Address").font(.headline).bold()

        LabelTextField(label: "Unit", placeHolder: "Unit", input: $Unit, error: $UnitStatus, error_message: "No Unit Inserted")
            .frame(width: width-200)
        LabelTextField(label: "Address", placeHolder: "Address", input: $Address, error: $AddressStatus, error_message: "No Address Inserted")
            .frame(width: width-200)
        LabelTextField(label: "City", placeHolder: "City", input: $City, error: $CityStatus, error_message: "No City Inserted")
            .frame(width: width-200)
        LabelTextField(label: "State", placeHolder: "State", input: $State, error: $StateStatus, error_message: "No State Inserted")
            .frame(width: width-200)
        LabelTextField(label: "Postcode", placeHolder: "Postcode", input: $PostCode, error: $PostCodeStatus, error_message: "No Postcode Inserted")
            .frame(width: width-200)
        */
    }
    
}

//https://github.com/stripe/stripe-ios/issues/1204
 //https://stripe.com/docs/payments/accept-a-payment
struct CheckoutView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    @State var checkout:Checkout?
    
    var body: some View {
        
        VStack {
            
            if let checkout = checkout {
                
                iPhoneCheckOutView(checkout: checkout)

            }
            
            else {
                ProgressView()
            }
            
        }
        .onAppear(perform: {getCheckoutData()})
        .offset(y: 15)
        
        .toast(isPresenting: $viewModel.show){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)

        }
        
        
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
                     let count = 0
                     
                     if(count == 0) {
                         
                         Image(systemName: "cart").imageScale(.large)

                     }
                     else{
                         ZStack {
                             Image(systemName: "cart").imageScale(.large)
                             Text("\(0)")
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
    
    func getCheckoutData() {
        API(user: user).getCheckout() { (result) in
            switch result {
            case .success(let checkout):
                DispatchQueue.main.async {
                    self.checkout = checkout
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true            }
        }
    }
}



struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}




