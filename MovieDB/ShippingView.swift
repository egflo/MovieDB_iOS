//
//  ShippingView.swift
//  MovieDB
//
//

import SwiftUI
import CoreData
import UIKit
import URLImage
import SDWebImageSwiftUI
import Combine
import UIKit
import Introspect
import AlertToast
import Stripe
import KeychainAccess



struct ShippingView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @EnvironmentObject var viewModel: AlertViewModel
    
    @EnvironmentObject var userData: UserData
    @State var address = Address()

    @State var isActive = false
    @State var isCheckoutActive = false
    
    @State var firstNameStatus: Bool = false
    @State var lastNameStatus: Bool = false
    @State var addressStatus: Bool = false
    @State var unitStatus: Bool = false
    @State var cityStatus: Bool = false
    @State var stateStatus: Bool = false
    @State var postcodeStatus: Bool = false
    
    @State var errorFirstName = "No First Name Inserted"
    @State var errorLastName = "No Last Name Inserted"
    @State var errorUnit = "No Unit Inserted"
    @State var errorAddress = "Address is Required"
    @State var errorCity = "City is Required"
    @State var errorState = "No State Inserted"
    @State var errorPoastcode = "Postcode is Required"

    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        ScrollView {
                Group {
                    LabelTextField(label: "Firstname", placeHolder: "", input: $address.firstname, error: $firstNameStatus, error_message: $errorFirstName)
                    
                    LabelTextField(label: "Lastname", placeHolder: "", input: $address.lastname, error: $lastNameStatus, error_message: $errorLastName)
                        
                    LabelTextField(label: "Unit", placeHolder: "Aot, Suite, Unit, Building (Optional)", input: $address.unit, error: $unitStatus, error_message: $errorUnit)
                    
                    LabelTextField(label: "Address", placeHolder: "Street Number, Stree Address", input: $address.street, error: $addressStatus, error_message: $errorAddress)
                    
                    LabelTextField(label: "City", placeHolder: "City, Town", input: $address.city, error: $cityStatus, error_message: $errorCity)
                    
                    HStack {
                        LabelTextField(label: "State", placeHolder: "", input: $address.state, error: $stateStatus, error_message: $errorState)
                            .frame(width: 150)
                        
                        Spacer().frame(width: 10)
                        
                        LabelTextField(label: "Postcode", placeHolder: "Zipcode", input: $address.postcode, error: $postcodeStatus, error_message: $errorPoastcode)
                        
                    }//.frame(width: width)

                }
                
                Button(action: {
                    print("Saving Address")
                    validate()
                }) {
                    
                    Text("Continue To Checkout").bold()
                        .frame(maxWidth: .infinity, minHeight:50, maxHeight: 50)
                        //You need to change height & width as per your requirement
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.bottom,5)
                        .padding(.top, 5)
                        
                    }
                
            Spacer()
        }
        .background(
            HStack {
                NavigationLink(destination: CheckoutView(), isActive: $isActive) {EmptyView()}
            }
        )

        .padding(.leading, 15)
        .padding(.trailing, 15)
        .frame(maxWidth: 600)
                
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Address Information"), displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }
    
    func validPostal(postcode: String) -> Bool {
        let regex =  "[0-9]{5}"
        let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
        return namePredicate.evaluate(with: postcode)
    }
    
    func validate() {
        var points = 0
        
        let firstName = address.firstname.trimmingCharacters(in: .whitespaces)
        if(firstName.count == 0) {
            firstNameStatus = true

        }
        else {
            firstNameStatus = false
            points += 1

        }
        
        let lastName = address.lastname.trimmingCharacters(in: .whitespaces)
        if(lastName.count == 0) {
            lastNameStatus = true

        }
        else {
            lastNameStatus = false
            points += 1

        }
        
        let addressAddress = address.street.trimmingCharacters(in: .whitespaces)
        if(addressAddress.count == 0) {
            addressStatus = true

        }
        else {
            addressStatus = false
            points += 1

        }
        
        let city = address.city.trimmingCharacters(in: .whitespaces)
        if(city.count == 0) {
            cityStatus = true

        }
        else {
            cityStatus = false
            points += 1

        }
        
        let state = address.state.trimmingCharacters(in: .whitespaces)
        if(state.count == 0) {
            stateStatus = true

        }
        else {
            stateStatus = false
            points += 1

        }
        
        let postcode = address.postcode.trimmingCharacters(in: .whitespaces)
        if(postcode.count == 0 || !validPostal(postcode: postcode)) {
            postcodeStatus = true

        }
        else {
            postcodeStatus = false
            points += 1

        }
        
        if(points >= 6) {
            let address = Address(id: address.id, firstname: address.firstname, lastname: address.lastname, street: address.street, unit: address.unit, city: address.city, state: address.state, postcode: address.postcode)
            uploadAddress(address: address)
        }
        
    }
    
    
    func uploadAddress(address: Address) {
        
         API(user: userData).uploadAddress(address: address, insert: true) { (result) in
             switch result {
             case .success(let address):
                 DispatchQueue.main.async {
                     isCheckoutActive = true
                     
                 }
             case .failure(let error):
                 DispatchQueue.main.async {
                     viewModel.setError(title: "Error", subtitle: error.localizedDescription)

                     
                 }
             }
         }

    }
}
