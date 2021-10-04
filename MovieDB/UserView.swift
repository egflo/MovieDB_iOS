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

struct CustomTextField: TextFieldStyle {
    @Binding var focused: Bool
    //@Binding var error: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(focused ? Color.red : Color(.systemGray6), lineWidth: 3)
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
                .background(Color(.systemGray5))
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
    @State var user: User
    @State var qty = 0
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    @State var newPasswordStatus: Bool = false
    @State var newConfirmPasswordStatus: Bool = false
    @State var passwordStatus: Bool = false
    
    @State var newPassword: String = ""
    @State var newConfirmPassword: String = ""
    @State var password: String = ""

    @State var errorNewPassword = ""
    @State var errorNewConfirmPassword = ""
    @State var errorPassword = ""

    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        
        VStack {
            //Text("Change Password").font(.title).bold().frame(width:width, alignment: .leading)
            
            LabelSecureTextField(label: "Old Password", placeHolder: "Old Password", input: $password, error: $passwordStatus, error_message: $errorPassword)
            
            Divider()
            
            LabelSecureTextField(label: "New Password", placeHolder: "New Password", input: $newPassword, error: $newPasswordStatus, error_message: $errorNewPassword)

            LabelSecureTextField(label: "Confirm Password", placeHolder: "Confirm Password", input: $newConfirmPassword, error: $newConfirmPasswordStatus, error_message: $errorNewConfirmPassword)

            
            Button(action: {
                print("Saving Password")
                validate()
            }) {
                
                Text("Save Changes").bold()
                    .frame(width: width , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom,5)
                    .padding(.top, 5)
                    
                }
          
            Spacer()

        }
        .frame(width:width)
        
        .onAppear(perform:{
            //self.getUserData()
            //self.getCartQtyData()
        })
        //.offset(y: 15)
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Change Password"), displayMode: .large)
        
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
          ToolbarItem(placement: .bottomBar) {
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
    
    func validate() {
        
        if(password.count == 0) {
            passwordStatus = true
            errorPassword = "Password is required"
            return
        }
        
        print("Valid Form Submited")
        
    }
    
}

struct EmailView: View {
    @State var user: User
    @State var qty = 0
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
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
        
        VStack {
            //Text("Change Email").font(.title).bold().frame(width:width, alignment: .leading)
            Divider()

            Text("Current email: \(user.email)")
                .bold()
                .padding(.bottom)
                .padding(.top)
                .font(.headline)
                .frame(width:width, alignment: .leading)
            
            Divider()
            
            LabelTextField(label: "New Email", placeHolder: "New Email", input: $newEmail, error: $emailStatus, error_message: $errorNewEmail)
            
            LabelTextField(label: "Confirm Email", placeHolder: "Confirm Email", input: $confirmEmail, error: $emailConfirmStatus, error_message: $errorConfirmEmail)

            LabelSecureTextField(label: "Password", placeHolder: "Password", input: $password, error: $passwordStatus, error_message: $errorPassword)
            
            Button(action: {
                print("Saving Address")
                validate()
            }) {
                
                Text("Save Changes").bold()
                    .frame(width: width , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom,5)
                    .padding(.top, 5)
                    
                }
            
            Spacer()
            
        }
        .frame(width:width)
        //.offset(y: 15)
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Change Email"), displayMode: .large)
        
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
          ToolbarItem(placement: .bottomBar) {
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
    
    func validEmail(email: String) -> Bool {
        let regex =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
        return namePredicate.evaluate(with: email)
    }
    
    func validate() {
        
        let email = newEmail.trimmingCharacters(in: .whitespaces)
        let confirmEmail = confirmEmail.trimmingCharacters(in: .whitespaces)

        if(email.count == 0) {
            emailStatus = true
            errorNewEmail = "Email is required"
            return

        }
        
        if(!validEmail(email: email)) {
            emailConfirmStatus = true
            errorNewEmail = "Email not a valid format"
            return
        }
        
        if(confirmEmail != email) {
            emailConfirmStatus = true
            errorConfirmEmail = "Email(s) do not match"
            return

        }
        
        if(password.count == 0) {
            passwordStatus = true
            errorPassword = "Password is required"
            return
        }
        
        
        print("Valid Form Submited")
        
    }
    
}


struct AddressView: View {
    @State var user: User
    @State var qty = 0
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    @State var addressStatus: Bool = false
    @State var unitStatus: Bool = false
    @State var cityStatus: Bool = false
    @State var stateStatus: Bool = false
    @State var postcodeStatus: Bool = false
    
    @State var errorUnit = "No Unit Inserted"
    @State var errorAddress = "Address is Required"
    @State var errorCity = "City is Required"
    @State var errorState = "No State Inserted"
    @State var errorPoastcode = "Postcode is Required"

    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        VStack {
            let userDecode = UserDecode(user: user)
            Group {
                
                //Text("Change Address").font(.title).bold().frame(width:width, alignment: .leading)
            
                LabelTextField(label: "Unit", placeHolder: "Aot, Suite, Unit, Building (Optional)", input: $user.unit, error: $unitStatus, error_message: $errorUnit)
                
                LabelTextField(label: "Address", placeHolder: "Street Number, Stree Address", input: $user.address, error: $addressStatus, error_message: $errorAddress)
                
                LabelTextField(label: "City", placeHolder: "City, Town", input: $user.city, error: $cityStatus, error_message: $errorCity)
                
                HStack {
                    LabelTextField(label: "State", placeHolder: "", input: $user.state, error: $stateStatus, error_message: $errorState)
                        .frame(width: 150)
                    
                    Spacer().frame(width: 10)
                    
                    LabelTextField(label: "Postcode", placeHolder: "Zipcode", input: $user.postcode, error: $postcodeStatus, error_message: $errorPoastcode)
                    
                }.frame(width: width)

            }
            
            
            Button(action: {
                print("Saving Address")
                validate()
            }) {
                
                Text("Save Changes").bold()
                    .frame(width: width , height: 50, alignment: .center)
                    //You need to change height & width as per your requirement
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.bottom,5)
                    .padding(.top, 5)
                    
                }
            
            Spacer()
            
        }
        .frame(width:width)
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("Change Address"), displayMode: .large)
        
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
          ToolbarItem(placement: .bottomBar) {
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
    
    func validPostal(postcode: String) -> Bool {
        let regex =  "[0-9]{5}"
        let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
        return namePredicate.evaluate(with: postcode)
    }
    
    func validate() {
        var points = 0
        
        let address = user.address.trimmingCharacters(in: .whitespaces)
        if(address.count == 0) {
            addressStatus = true

        }
        else {
            addressStatus = false
            points += 1

        }
        
        let city = user.city.trimmingCharacters(in: .whitespaces)
        if(city.count == 0) {
            cityStatus = true

        }
        else {
            cityStatus = false
            points += 1

        }
        
        let state = user.state.trimmingCharacters(in: .whitespaces)
        if(state.count == 0) {
            stateStatus = true

        }
        else {
            stateStatus = false
            points += 1

        }
        
        let postcode = user.postcode.trimmingCharacters(in: .whitespaces)
        if(postcode.count == 0 || !validPostal(postcode: postcode)) {
            postcodeStatus = true

        }
        else {
            postcodeStatus = false
            points += 1

        }
        
    }
}

struct UserView: View {
    @EnvironmentObject var user: UserData
    
    @State var qty = 0
    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
    
    @State var userData: User?
    @State var device = false
    @State var updateSuccess = false
    @State var updateFaliure = false


    let width = (UIScreen.main.bounds.width - 33)
    let height = (UIScreen.main.bounds.height - 33)
    

    //https://www.reddit.com/r/swift/comments/ppfoys/found_nil_while_unwrapping/
    
    
    
    var body: some View {
        //let user_decode = UserDecode(user: self.data)
        VStack{
            Text("Account Settings").font(.title).bold().frame(width: width, alignment: .leading)

            if let user = userData {
                
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

            
                    NavigationLink(destination: AddressView(user: user)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Primary Address").bold()
                                    .foregroundColor(Color.blue)

                                Text("\(user.address), \(user.city) \(user.state) \(user.postcode)")
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
            self.getCartQtyData()
        })
        .offset(y: 15)

        
        .navigationBarHidden(true)
        .navigationBarTitle(Text("Account Settings"), displayMode: .large)
        
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
          ToolbarItem(placement: .bottomBar) {
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
    
    func getUserData() {
        API(user: user).getUser(){ (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.userData = user
                }
            case .failure(let error):
                print(error.localizedDescription)
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

struct UserAccount_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
