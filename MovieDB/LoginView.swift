//
//  LoginView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/28/21.
//

import SwiftUI
import KeychainAccess
import AlertToast


struct LoginView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    @State private var email: String = ""
    @State private var password: String = ""
   
    @State private var title: String = "Error"
    @State private var message: String = ""
    @State private var showToast = false

    
    @State private var loading = false
    
    let verticalPaddingForForm = 30
    
    var body: some View {
        ZStack {
            VStack(spacing: CGFloat(verticalPaddingForForm)) {
                Image(systemName: "film")
                    .resizable()
                    .frame(width: 100, height: 100).foregroundColor(.secondary)
                                
               HStack {
                    Image(systemName: "envelope.fill")
                       .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .shadow(radius: 8)
                
                HStack {
                    Image(systemName: "key")
                        .resizable()
                        .frame(width: 12, height: 20)
                        .foregroundColor(.gray)
                    SecureField("Password", text: $password)
                        .foregroundColor(.gray)

                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .shadow(radius: 8)

                
                Button(action:  {
                        self.loading = true
                        authUser()
                        
                    
                }) {
                    Text("Login").bold()
                        .padding()
                    
                    if(self.loading){
                        ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))

                    }
                    
                }.frame(width: 150, height: 50)

                .background(Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                
          }.padding(.horizontal, CGFloat(verticalPaddingForForm))
            
        }.frame(maxWidth: 600)
        
        .toast(isPresenting: $showToast){

            //Choose .hud to toast alert from the top of the screen
            AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)

        }
    }
    
    func authUser() {
        API(user: user).authUser(username: email, password: password) { (result) in
            switch result {
            case .success(let userToken):
                DispatchQueue.main.async {
                    user.isLoggedin = true
                    user.id = userToken.id
                    user.username = userToken.username
                    user.token = userToken.token
                    
                    self.loading = false
                    
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserData
    

    var body: some View {
          if !user.isLoggedin {
                //return AnyView(LoginView())
                //AnyView(LoginView())
               LoginView()
           } else {
               // return AnyView(SearchView())
                NavigationView {
                    MainView()
                        //.transition(.move(edge: .trailing))
                        //.animation(Animation.linear(duration: 2))
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
