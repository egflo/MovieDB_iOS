//
//  GenreView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/19/21.
//

import SwiftUI
import URLImage
import AlertToast

struct GenreView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel

    var genre: Genre
    
    @State var movies = [Movie]()
    @StateObject var dataSource = ContentDataSourceTest<Movie>()
    

    var body: some View {
            
        ScrollView{
            LazyVStack {
                /*
                ForEach(dataSource.items, id: \.id) { movie in
                    if(dataSource.items.last == movie){
                        MovieRow(movie: movie)
                            .frame(width: (UIScreen.main.bounds.width - 33), height: 80)
                            .onAppear {
                                dataSource.loadMoreContent(user: user)
                            }
                    }
                    else {
                        MovieRow(movie: movie)
                            .frame(width: (UIScreen.main.bounds.width - 33), height: 80)
                        
                        Divider()
                    }
                    
                }
                
                .navigationBarTitle("\(genre.name)")
                 */
                
            } .onAppear {
                //dataSource.query = "genre"
                //dataSource.setText(text: genre.name, user: user)
                
            }
            
        
            if dataSource.isLoadingPage {
                ProgressView() //A view that shows the progress towards completion of a task.
            }
            
       }
        
        .navigationBarHidden(false)
        .navigationBarTitle(Text("\(genre.name)"), displayMode: .large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                ItemsToolbar()
            }
        }
    }
    
}
