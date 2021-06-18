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


struct CustomTextField: TextFieldStyle {
    @Binding var focused: Bool
    //@Binding var error: Bool
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
            .stroke(focused ? Color.blue : Color.gray, lineWidth: 2)
        )
    }
}

struct LabelTextField : View {
    var label: String
    var placeHolder: String
    @Binding var input: String
    @Binding var error: Bool
    var error_message: String
 
    @State private var editing = false

    var body: some View {
 
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack{
                Text(label)
                    .font(.headline).bold()
               
                Spacer()
                if(error) {
                    Text(error_message)
                        .font(.subheadline).bold()
                        .foregroundColor(Color.red)
                }
 
            }
            
            TextField("\(placeHolder)", text: $input, onEditingChanged: {edit in self.editing = edit})
                .textFieldStyle(CustomTextField(focused: $editing))
            
        }
    }
}



struct UserView: View {
    @EnvironmentObject var user: User
    
    @State var data = UserData()

    
    @State var HomeActive = false
    @State var SearchActive = false
    @State var UserActive = false
    @State var OrderActive = false
    @State var CartActive = false
    
        
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var address: String = ""
    @State var unit: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var city: String = ""
    @State var state: String = ""
    @State var postcode: String = ""
    
    
    @State var firstNameStatus: Bool = false
    @State var lastNameStatus: Bool = false
    @State var addressStatus: Bool = false
    @State var unitStatus: Bool = false
    @State var emailStatus: Bool = false
    @State var passwordStatus: Bool = false
    @State var cityStatus: Bool = false
    @State var stateStatus: Bool = false
    @State var postcodeStatus: Bool = false
    
    
    @State var updateSuccess = false
    @State var updateFaliure = false


    //let width = (UIScreen.main.bounds.width - 33)
   // let height = (UIScreen.main.bounds.height - 33)
    
    
    //Source: https://www.simpleswiftguide.com/how-to-make-http-put-request-with-json-as-data-in-swift/
    func uploadUser() {
        let baseURL = URL(string: MyVariables.API_IP)!
        let fullURL = baseURL.appendingPathComponent("/customer/\(data.id)")

        var request = URLRequest(url: fullURL)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        
        struct UploadData: Codable {
            let firstName: String
            let lastName: String
            let address: String
            let unit: String
            let email: String
            let password: String
            let city: String
            let state: String
            let postcode: String
        }
        
        
        let uploadDataModel = UploadData(firstName: data.firstName, lastName: data.lastName, address: data.address, unit: data.unit, email: data.email, password: data.email, city: data.city, state: data.state, postcode: data.postcode)

        
        guard let data = try? JSONEncoder().encode(uploadDataModel) else {
             print("Error: Trying to convert model to JSON data")
             self.updateFaliure = true
             return
         }
        
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                self.updateFaliure = true
                return
            }
            
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    self.updateFaliure = true
                    return
                }
                
                //if let responseJSONData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: responseData) {
                    print("Response JSON data = \(decodedResponse)")
                    self.data = decodedResponse
                    self.updateSuccess = true

                }
            }
        }.resume()
        
        
    }
    
    
    func loadUser() {
        
        let url = "\(MyVariables.API_IP)/customer/\(user.data.id)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        self.data = decodedResponse

                    }
                    // everything is good, so we can exit
                    return
                }
            }

        }.resume()
    }
    
    func validEmail(email: String) -> Bool {
        let regex =  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let namePredicate = NSPredicate(format: "SELF MATCHES%@", regex)
        return !namePredicate.evaluate(with: email)
    }
    
    
    func validate() {
        
        var points = 0
        
        let firstName = data.firstName.trimmingCharacters(in: .whitespaces)
        if(firstName.count == 0) {
            firstNameStatus = true
        }
        else {
            firstNameStatus = false
            points += 1
        }
        
        let lastName = data.lastName.trimmingCharacters(in: .whitespaces)
        if(lastName.count == 0) {
            lastNameStatus = true

        }
        else {
            lastNameStatus = false
            points += 1

        }
            
        let address = data.address.trimmingCharacters(in: .whitespaces)
        if(address.count == 0) {
            addressStatus = true

        }
        else {
            addressStatus = false
            points += 1

        }
        
        let email = data.email.trimmingCharacters(in: .whitespaces)
        if(email.count == 0) || (validEmail(email: email)) {
            emailStatus = true

        }
        else {
            emailStatus = false
            points += 1

        }
        
        let city = data.city.trimmingCharacters(in: .whitespaces)
        if(city.count == 0) {
            cityStatus = true

        }
        else {
            cityStatus = false
            points += 1

        }
        
        let state = data.state.trimmingCharacters(in: .whitespaces)
        if(state.count == 0) {
            stateStatus = true

        }
        else {
            stateStatus = false
            points += 1

        }
        
        let postcode = data.postcode.trimmingCharacters(in: .whitespaces)
        if(postcode.count == 0) {
            postcodeStatus = true

        }
        else {
            postcodeStatus = false
            points += 1

        }
        
        let password = data.password.trimmingCharacters(in: .whitespaces)
        if(password.count == 0) {
            passwordStatus = true

        }
        else {
            passwordStatus = false
        }
        
        if(points >= 7) {
            self.uploadUser()
        }
        
    }
    
    
    @State var device = false
    
    var body: some View {
        let user_decode = UserDecode(user: self.data)
        VStack{
            
            GeometryReader { geometry in
                var width = geometry.size.width-33
                
                
                ScrollView{
                    VStack{
                        Text("Account Settings").font(.title).bold()
                            .frame(width:width, alignment: .leading)
                    
                        Group {
                            Text("Personal Information")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color.gray)
                                .padding(.bottom,5)
                                .padding(.top, 5)
                            
                            
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    
                                    
                                    LabelTextField(label: "First Name", placeHolder: user_decode.firstName(), input: $data.firstName, error: $firstNameStatus, error_message: "No First Name Inserted")
                                        .frame(width: width-200)
                                    LabelTextField(label: "Last Name", placeHolder: user_decode.lastName(), input: $data.lastName, error: $lastNameStatus, error_message: "No Last Name Inserted")
                                        .frame(width: width-200)
                                    LabelTextField(label: "Email", placeHolder: user_decode.email(), input: $data.email, error: $emailStatus, error_message: "No/Invalid Email Inserted")
                                        .frame(width: width-200)
                                    LabelTextField(label: "Password", placeHolder: user_decode.password(), input: $data.password, error: $passwordStatus, error_message: "No Email Inserted")
                                        .frame(width: width-200)

                                
                                }
                                
                                else {
                                    
                                    LabelTextField(label: "First Name", placeHolder: user_decode.firstName(), input: $data.firstName, error: $firstNameStatus, error_message: "No First Name Inserted")
                                        .frame(width: width)
                                    LabelTextField(label: "Last Name", placeHolder: user_decode.lastName(), input: $data.lastName, error: $lastNameStatus, error_message: "No Last Name Inserted")
                                        .frame(width: width)
                                    LabelTextField(label: "Email", placeHolder: user_decode.email(), input: $data.email, error: $emailStatus, error_message: "No/Invalid Email Inserted")
                                        .frame(width: width)
                                    LabelTextField(label: "Password", placeHolder: user_decode.password(), input: $data.password, error: $passwordStatus, error_message: "No Email Inserted")
                                        .frame(width: width)
                                    
                                }

                        }
                        


                        Group {
                            Text("Address Information")
                                .font(.headline)
                                .bold()
                                .foregroundColor(Color.gray)
                                .padding(.bottom,5)
                                .padding(.top, 10)
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                
                                LabelTextField(label: "Unit", placeHolder: user_decode.unit(), input: $data.unit, error: $unitStatus, error_message: "No Unit Inserted")
                                    .frame(width: width-200)
                                LabelTextField(label: "Address", placeHolder: user_decode.address(), input: $data.address, error: $addressStatus, error_message: "No Address Inserted")
                                    .frame(width: width-200)
                                LabelTextField(label: "City", placeHolder: user_decode.city(), input: $data.city, error: $cityStatus, error_message: "No City Inserted")
                                    .frame(width: width-200)
                                LabelTextField(label: "State", placeHolder: user_decode.state(), input: $data.state, error: $stateStatus, error_message: "No State Inserted")
                                    .frame(width: width-200)
                                LabelTextField(label: "Postcode", placeHolder: user_decode.postcode(), input: $data.postcode, error: $postcodeStatus, error_message: "No Postcode Inserted")
                                    .frame(width: width-200)

                            }
                            
                            else {
                                LabelTextField(label: "Unit", placeHolder: user_decode.unit(), input: $data.unit, error: $unitStatus, error_message: "No Unit Inserted")
                                    .frame(width: width)
                                LabelTextField(label: "Address", placeHolder: user_decode.address(), input: $data.address, error: $addressStatus, error_message: "No Address Inserted")
                                    .frame(width: width)
                                LabelTextField(label: "City", placeHolder: user_decode.city(), input: $data.city, error: $cityStatus, error_message: "No City Inserted")
                                    .frame(width: width)
                                LabelTextField(label: "State", placeHolder: user_decode.state(), input: $data.state, error: $stateStatus, error_message: "No State Inserted")
                                    .frame(width: width)
                                LabelTextField(label: "Postcode", placeHolder: user_decode.postcode(), input: $data.postcode, error: $postcodeStatus, error_message: "No Postcode Inserted")
                                    .frame(width: width)
                                
                            }

                        }.frame(width:geometry.size.width, alignment: .center)

                        
                        Button(action: {
                            print("checkout")
                            validate()
                        }) {
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                
                                Text("Save Changes").bold()
                                    //.frame(width: 200 , height: 50, alignment: .center)
                                    //You need to change height & width as per your requirement
                                    .frame(width: width-200, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .padding(.bottom,5)
                                    .padding(.top, 5)

                            }
                            
                            else {
                                
                                Text("Save Changes").bold()
                                    //.frame(width: 200 , height: 50, alignment: .center)
                                    //You need to change height & width as per your requirement
                                    .frame(width: geometry.size.width-33, height: 50)
                                    .foregroundColor(Color.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .padding(.bottom,5)
                                    .padding(.top, 5)
                                
                            }

                        }
                        
                        VStack {
                            
                        }
                        .spAlert(isPresent: $updateSuccess, message: "Information Updated", duration:2.0, dismissOnTap: true, layout: .init())
                           .offset( x:(geometry.size.width/2)-100, y: geometry.size.height-70)
                       
                        .spAlert(isPresent: $updateFaliure, message: "Something went wrong. Try again later.", duration:2.0, dismissOnTap: true, preset: .custom(UIImage.init(systemName: "xmark")!),  layout: .init())
                          .offset( x:(geometry.size.width/2)-100, y: geometry.size.height-70)
                        
                    }.onAppear{loadUser()}
                }


            }
            
            
        }
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
                     let count = user.getCartCount()
                     
                     if(count == 0) {
                         
                         Image(systemName: "cart").imageScale(.large)

                     }
                     else{
                         ZStack {
                             Image(systemName: "cart").imageScale(.large)
                             Text("\(user.getCartCountStr())")
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
    
}

struct UserAccount_Previews: PreviewProvider {
    static var previews: some View {
        UserView()
    }
}
