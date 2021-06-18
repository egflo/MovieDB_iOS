//
//  LoginView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/28/21.
//

import SwiftUI
import KeychainAccess


struct LoginView: View {
    @EnvironmentObject var user: User


    @State private var email: String = ""
    @State private var password: String = ""
    @State private var message: String = ""
    
    let verticalPaddingForForm = 30.0
    var body: some View {
        ZStack {
            VStack(spacing: CGFloat(verticalPaddingForForm)) {
                Image(systemName: "film")
                    .resizable()
                    .frame(width: 100, height: 100).foregroundColor(.secondary)
                
                Text(message).foregroundColor(Color.red)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .foregroundColor(Color.black)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 8)
                //.overlay(
                //     RoundedRectangle(cornerRadius: 10)
                //         .stroke(Color.gray, lineWidth: 2)
               //  )
                
                HStack {
                    Image(systemName: "key")
                        .resizable()
                        .frame(width: 12, height: 20) .foregroundColor(.secondary)
                    SecureField("Password", text: $password)
                        .foregroundColor(Color.black)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 8)
                //.overlay(
                //     RoundedRectangle(cornerRadius: 10)
                //         .stroke(Color.gray, lineWidth: 2)
                // )
                
                Button(action:  {
                        loadUser()
                    
                }) {
                    Text("Login").bold()
                        .padding()
                    
                }.frame(width: 100, height: 50)

                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                
            }.padding(.horizontal, CGFloat(verticalPaddingForForm))
            
        }
        .offset(y: -70)
    }
    
    func loadUser() {
        
        let url = "\(MyVariables.API_IP)/customer/auth?email=\(self.email)&password=\(password)"
        let encoded_url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        guard let url = URL(string: encoded_url!) else {
            let status = "Invalid URL"
            print(status)
            self.message = "Error Connecting to DataFlix. Try Again Later."
            return
        }
        
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(UserData.self, from: data) {
                    // we have good data – go back to the main thread
                    DispatchQueue.main.async {
                        // update our UI
                        user.data = decodedResponse
                        if(user.data.id != 0) {
                            user.isLoggedin = true
                        }
                        else {
                            self.message = "Email/Password Incorrect."
                        }
                    
                    }
                    // everything is good, so we can exit
                    return
                }
            }
            
            self.message = "Email/Password Incorrect."
        }.resume()
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: User
    

    var body: some View {
          if !user.isLoggedin {
                //return AnyView(LoginView())
                //AnyView(LoginView())
               LoginView()
           } else {
               // return AnyView(SearchView())
                NavigationView {
                    MainView()
                        .transition(.move(edge: .trailing))
                        .animation(Animation.linear(duration: 2))
                    //AnyView(MainView())
                }.navigationViewStyle(StackNavigationViewStyle())
         }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
