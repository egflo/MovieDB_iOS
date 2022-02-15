//
//  UserAccount.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/28/21.
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

struct CustomTextField: TextFieldStyle {
    @Binding var focused: Bool
    //@Binding var error: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(focused ? Color.red : Color(.systemGray6), lineWidth: 3)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                //.background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.white))

        )
    }
}

struct LabelTextField : View {

    var label: String
    var placeHolder: String
    @Binding var input: String
    @Binding var error: Bool
    @Binding var error_message: String

    @State private var editing = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            HStack{
                Text(label)
                    .font(.headline).bold()
                    .frame(height: 20)
               
                Spacer()
                if(error) {
                    Text(error_message)
                        .font(.subheadline).bold()
                        .foregroundColor(Color.red)
                }
 
            }.frame(height: 30)
            
            TextField("\(placeHolder)", text: $input, onEditingChanged: {edit in self.editing = edit})
                .textFieldStyle(CustomTextField(focused: $error))
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
            }
        }
    }
}

struct LabelSecureTextField : View {

    var label: String
    var placeHolder: String
    @Binding var input: String
    @Binding var error: Bool
    @Binding var error_message: String
 
    @State private var editing = false

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            HStack{
                Text(label)
                    .font(.headline).bold()
                    .frame(height: 20)
               
                Spacer()
                if(error) {
                    Text(error_message)
                        .font(.subheadline).bold()
                        .foregroundColor(Color.red)
                }
 
            }.frame(height: 30)
            
            SecureField("\(placeHolder)", text: $input)
                .background(Color(.systemGray5))
                .textFieldStyle(CustomTextField(focused: $error))
        }
    }
}


struct PasswordView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @State var user: User

    @State var newPasswordStatus: Bool = false
    @State var newConfirmPasswordStatus: Bool = false
    @State var passwordStatus: Bool = false
    
    @State var newPassword: String = ""
    @State var newConfirmPassword: String = ""
    @State var password: String = ""

    @State var errorNewPassword = "Password is required"
    @State var errorNewConfirmPassword = "Password(s) Must Match"
    @State var errorPassword = "Password is required"

    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        
        ScrollView {
            LabelSecureTextField(label: "Old Password", placeHolder: "Old Password", input: $password, error: $passwordStatus, error_message: $errorPassword)
            
            Divider()
            
            LabelSecureTextField(label: "New Password", placeHolder: "New Password", input: $newPassword, error: $newPasswordStatus, error_message: $errorNewPassword)

            LabelSecureTextField(label: "Confirm Password", placeHolder: "Confirm Password", input: $newConfirmPassword, error: $newConfirmPasswordStatus, error_message: $errorNewConfirmPassword)

            
            Button(action: {
                print("Saving Password")
                validate()
            }) {
                
                Text("Save Changes").bold()
                    .frame(maxWidth: .infinity, minHeight:50, maxHeight: 50)
                    //.frame(width: width , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom,5)
                    .padding(.top, 5)
                    
                }
          
            Spacer()

        }
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .frame(maxWidth: 600)
        
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Change Password"), displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    
    }
    
    func validate() {
        
        var points = 0
        
        let password = password.trimmingCharacters(in: .whitespaces)
        if(password.count == 0) {
            passwordStatus = true

        }
        else {
            passwordStatus = false
            points += 1
        }
        
        let newPassword = newPassword.trimmingCharacters(in: .whitespaces)
        if(newPassword.count == 0) {
            newPasswordStatus = true

        }
        else {
            newPasswordStatus = false
            points += 1
        }
        
        let confirmPassword = newConfirmPassword.trimmingCharacters(in: .whitespaces)
        if(confirmPassword != newPassword) {
            newConfirmPasswordStatus = true

        }
        else {
            newConfirmPasswordStatus = false
            points += 1
        }
        
        
        if(points >= 3) {
            print("Valid Form Submited")
            let changePassword = Password(id: user.id, password: password, newPassword: newPassword)
            uploadPassword(password: changePassword)
        }
        
    }
    
    func uploadPassword(password: Password) {
        API(user: userData).uploadPassword(password: password) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    viewModel.setComplete(title: "Password Updated", subtitle: "Re-login with updated password.")
                    self.user = user
                    userData.isLoggedin = false

                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)
                    
                }
            }
        }
    }
}

struct EmailView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @State var user: User

    @State var emailStatus: Bool = false
    @State var emailConfirmStatus: Bool = false
    @State var passwordStatus: Bool = false
    
    @State var newEmail: String = ""
    @State var confirmEmail: String = ""
    @State var password: String = ""

    
    @State var errorNewEmail = ""
    @State var errorConfirmEmail = ""
    @State var errorPassword = ""

    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        
        ScrollView {
            //Text("Change Email").font(.title).bold().frame(width:width, alignment: .leading)
            Divider()

            Text("Current email: \(user.email)")
                .bold()
                .padding(.bottom)
                .padding(.top)
                .font(.headline)
                //.frame(width:width, alignment: .leading)
            
            Divider()
            
            LabelTextField(label: "New Email", placeHolder: "New Email", input: $newEmail, error: $emailStatus, error_message: $errorNewEmail)
            
            LabelTextField(label: "Confirm Email", placeHolder: "Confirm Email", input: $confirmEmail, error: $emailConfirmStatus, error_message: $errorConfirmEmail)

            LabelSecureTextField(label: "Password", placeHolder: "Password", input: $password, error: $passwordStatus, error_message: $errorPassword)
            
            Button(action: {
                print("Saving Address")
                validate()
            }) {
                
                Text("Save Changes").bold()
                    .frame(maxWidth: .infinity, minHeight:50, maxHeight: 50)
                    //frame(width: width , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom,5)
                    .padding(.top, 5)
                    
                }
            
            Spacer()
            
        }
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .frame(maxWidth: 600)
        
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Change Email"),displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }

    }
    
    func validEmail(email: String) -> Bool {
        let regex =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
        return namePredicate.evaluate(with: email)
    }
    
    func validate() {
        var points = 0
        let email = newEmail.trimmingCharacters(in: .whitespaces)
        let confirmEmail = confirmEmail.trimmingCharacters(in: .whitespaces)

        if(email.count == 0) {
            emailStatus = true
            errorNewEmail = "Email is required"
        }
        else {
            emailStatus = false
            points += 1
        }
        
        if(!validEmail(email: email)) {
            emailConfirmStatus = true
            errorNewEmail = "Email not a valid format"
        }
        
        else {
            emailConfirmStatus = false
            points += 1
        }
        
        if(confirmEmail != email) {
            emailConfirmStatus = true
            errorConfirmEmail = "Email(s) do not match"
        }
        else {
            emailConfirmStatus = false
            points += 1
        }
        
        if(password.count == 0) {
            passwordStatus = true
            errorPassword = "Password is required"
        }
        else {
            passwordStatus = false
            points += 1
        }
        
        
        if(points >= 3) {
            print("Email Form Submited")
            let email = Email(id: user.id, email: user.email, newEmail: newEmail, password: password)
            uploadEmail(email: email)
        }
        
    }
    
    func uploadEmail(email: Email) {
        API(user: userData).uploadEmail(email: email) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    viewModel.setComplete(title: "Email Updated", subtitle: "Re-login with updated email.")

                    self.user = user
                    userData.isLoggedin = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)
                    
                }
            }
        }
    }
    
}


struct AddressView: View {
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    @State var user: User
    @State var address: Address
    @State var insert: Bool
    
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
                    
                    Text("Save Changes").bold()
                        .frame(maxWidth: .infinity, minHeight:50, maxHeight: 50)
                        //You need to change height & width as per your requirement
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.bottom,5)
                        .padding(.top, 5)
                        
                    }
                
                if(!insert) {
                    Button(action: {
                        print("Making Default Address")
                        self.uploadDefaultAddress(address: address)
                    }) {
                        
                        Text("Make Default").bold()
                            .frame(maxWidth: .infinity, minHeight:50, maxHeight: 50)
                            //You need to change height & width as per your requirement
                            .foregroundColor(Color.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.bottom,5)
                            .padding(.top, 5)
                            
                        }
                }
            Spacer()
        }
        .background(
            HStack {
                //NavigationLink(destination: CheckoutView(), isActive: $isActive) {EmptyView()}
                NavigationLink(destination: UserView(), isActive: $isActive) {EmptyView()}
            }
        )

        .padding(.leading, 15)
        .padding(.trailing, 15)
        .frame(maxWidth: 600)
                
        .navigationBarHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle((insert) ? Text("Add Address") : Text("Change Address"), displayMode: .large)
        //.navigationBarTitle((insert) ? Text("Add Address") : Text("Change Address"), displayMode: .large)
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
    
    func uploadDefaultAddress(address: Address) {
        API(user: userData).uploadPrimaryAddressId(id: address.id) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                    viewModel.setComplete(title: "Success", subtitle: "Address is now primary address.")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)

                    
                }
            }
        }
    }
    
    func uploadAddress(address: Address) {
        
         API(user: userData).uploadAddress(address: address, insert: insert) { (result) in
             switch result {
             case .success(let address):
                 DispatchQueue.main.async {
                     if(insert) {
                         user.addresses.append(address)
                         self.mode.wrappedValue.dismiss()
                     }
                     
                     else {
                         //if let index = self.user.addresses.firstIndex(where: {$0.id == address.id}) {
                         //    user.addresses[index] = address
                         //}
                         self.address = address
                     }
                     //self.user = user
                     viewModel.setComplete(title: "Success", subtitle: "Address \((insert == true) ? "Added":"Updated")")
                     self.isActive = true
                     
                 }
             case .failure(let error):
                 DispatchQueue.main.async {
                     viewModel.setError(title: "Error", subtitle: error.localizedDescription)

                     
                 }
             }
         }

    }
}


struct AddressRowView: View {
    @State var address: Address
    @State var user: User
    
    var body: some View {
        NavigationLink(destination: AddressView(user: user, address: address, insert: false)) {
            HStack {
                VStack(alignment: .leading) {
                    
                    if(address.id == user.primaryAddress) {
                        
                        Text("Primary Address").bold()
                            .foregroundColor(Color.blue)
                    }

                    VStack(alignment: .leading) {
                        Text("\(address.firstname) \(address.lastname)")
                        Text("\(address.street), \(address.city) \(address.state) \(address.postcode)")
                    }
       
                }
                           
                Spacer()

                Text("Change")
                    .foregroundColor(Color.blue)
                
            }.frame(height: (address.id == user.primaryAddress) ? 80:50)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddressesView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    @State var user: User
    @State var addresses: [Address]?
    @State var isActive = false

    let width = (UIScreen.main.bounds.width)

    var body: some View {
        VStack {
            if let addresses = addresses {
                
                if(addresses.count == 0) {
                    GeometryReader {geometry in

                        VStack {
                            Image(systemName: "house")
                                .font(.system(size: 56.0))
                                .foregroundColor(.gray)

                            Text("There are no addresses your account.")
                                .fontWeight(.semibold)
                                .font(.system(size: 15.0))
                                .foregroundColor(.gray)

                        //-120
                        }.offset( x:(geometry.size.width/2)-130, y: (geometry.size.height/2)-120)
                    }
                }
                else {
                    List {
                        ForEach(addresses, id: \.id) { address in
                            
                            AddressRowView(address: address, user: user)

                        }
                        .onDelete(perform: removeAddressData)
                    }
                    
                }

            }
            
            else {
                ProgressView()
            }
        }
        .onAppear(perform: {
            self.getAddressData()
        })
        .frame(width:width)
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Addresses"), displayMode: .large)
        .navigationBarItems(trailing:
            Button(action: {
        }) {
            NavigationLink(destination: AddressView(user: user, address: Address(),  insert: true), isActive: $isActive) {
                Image(systemName: "plus")
            }
        })
        
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
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

    
    func removeAddressData(at offsets: IndexSet) {
        let index = offsets.first!
        let address = self.addresses![index]
        
        API(user: userData).deleteAddress(address: address){ (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.addresses!.remove(at: index)

                }
            case .failure(let error):
                viewModel.setError(title: "Error", subtitle: error.localizedDescription)
            }
        }
    }

}

struct UserView: View {
    @EnvironmentObject var userData: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    
    @State var user: User?
    @State var device = false
    @State var updateSuccess = false
    @State var updateFaliure = false

    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)
    let keychain = Keychain(service: "com.dataflix-token")

    //https://www.reddit.com/r/swift/comments/ppfoys/found_nil_while_unwrapping/
    var body: some View {
        //let user_decode = UserDecode(user: self.data)
        VStack{
            Text("Account Settings").font(.title).bold().frame(width: width, alignment: .leading)

            if let user = user {
                
                List {
                    
                    NavigationLink(destination: EmailView(user: user)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Email").bold()
                                    .foregroundColor(Color.blue)

                                Text("\(user.email)")
                            }
                                       
                            Spacer()
                            
                            Text("Change")
                                .foregroundColor(Color.blue)
                            
                        }.frame(height: 50)
                        
                    }.buttonStyle(PlainButtonStyle())

            
                    /**
                     
                     
                     
                     */
                    NavigationLink(destination: AddressesView(user: user)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Primary Address").bold()
                                    .foregroundColor(Color.blue)

                                if let address = user.addresses.first(where: {$0.id == user.primaryAddress}) {
                                    Text("\(address.street), \(address.city) \(address.state) \(address.postcode)")
                                } else {
                                   Text("No primary address selected.")
                                }
                            
                            }
                                       
                            Spacer()

                            Text("Change")
                                .foregroundColor(Color.blue)
                            
                        }.frame(height: 50)
                        
                    }.buttonStyle(PlainButtonStyle())
                    

                    

                    NavigationLink(destination: PasswordView(user: user)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Password").bold()
                                    .foregroundColor(Color.blue)

                                Text("**************")
                            }
                                       
                            Spacer()
                            
                            Text("Change")
                                .foregroundColor(Color.blue)
                            
                        }.frame(height: 50)
                        
                    }.buttonStyle(PlainButtonStyle())
                    
                }
                .frame(height: 250)
                .onAppear(perform: {
                    UITableView.appearance().isScrollEnabled = false
                })
                
                Button(action: {
                    print("Logout")
                    userData.isLoggedin = false
                    viewModel.setComplete(title: "Logged Out", subtitle: "You have been logged out.")
                    keychain["JWT"] = nil


                }) {
                    
                    Text("Logout").bold()
                        .frame(width: width , height: 50, alignment: .center)
                        //You need to change height & width as per your requirement
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(8)
                        .padding(.bottom,5)
                        .padding(.top, 5)
                        
                    }

                Spacer()
            }
            
            else {
                ProgressView()
            }
            
            Spacer()
            
        }
        .onAppear(perform:{
            self.getUserData()
        })
        
        .navigationBarHidden(true)
        .navigationBarTitle(Text("Account Settings"), displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }
    
    func getUserData() {
        API(user: userData).getUser(){ (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Error", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
}

struct UserAccount_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
