//
//  MovieView.swift
//  MovieDB
//
//  Created by Emmanuel Flores on 5/16/21.
//

import SwiftUI
import URLImage
import SDWebImageSwiftUI
import SPAlert
import AlertToast
import MapKit
import PopupView


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


struct BookmarkView: View {
    @EnvironmentObject var user: UserData

    @Binding var movie: Movie
    @State var bookmark: Bookmark?

    var body: some View {
        VStack {
            
            if let bookmark = bookmark {
                
                Button(action: {
                    print("Bookmark button pressed...")
                    updateBookmark()
                    
                })
                {
                    Image(systemName:(bookmark.id == 0) ? "plus.circle" : "minus.circle")
                            .font(.system(size: 25.0))
                            .foregroundColor(Color.blue)
                  
                }
            }
            
            else {
                
                Image(systemName: "circle.slash")
                     .font(.system(size: 25.0))
                     .foregroundColor(Color.blue)
                
            }
            
            
        }.onAppear(perform: {getBookmarkData()})

    }
    
    func getBookmarkData() {
        API(user: user).getBookmark(id: movie.id) { (result) in
            switch result {
            case .success(let bookmark):
                DispatchQueue.main.async {
                    self.bookmark = bookmark
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateBookmark() {
        API(user: user).updateBookmark(id: movie.id) { (result) in
            switch result {
            case .success(let bookmark):
                DispatchQueue.main.async {
                    self.bookmark = bookmark
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}


struct ReviewRow: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @EnvironmentObject var viewPopover: PopoverViewModel

    @State var review: Review
    
    var maximumRating = 5

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    

    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    ForEach(1..<maximumRating + 1) { number in
                        self.image(for: number)
                            .foregroundColor(number > rate() ? self.offColor : self.onColor)
                    }
                    
                    Image(systemName:(review.sentiment == "postive" ? "hand.thumbsup.fill": "hand.thumbsdown.fill"))
                            .font(.system(size: 15.0))
                            .foregroundColor( review.sentiment == "postive" ? Color.green : Color.red)
                            .padding(.top, 2)
                    
                    Spacer()
                }.padding(.bottom, 5)

                Text(review.title)
                    .font(.headline).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("By \(review.customerName)")
                    .font(.subheadline).bold()
                    .foregroundColor(Color.gray)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                //Divider().frame(width: width)
                
                Text(review.text)
                    .font(.subheadline).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    //.frame(width: .infinity, alignment: .leading)

                Spacer()
            }.onTapGesture(perform: {
                viewPopover.text = review.text
                viewPopover.show.toggle()
                
            })

        }

        

    }
    
    func rate() -> Int {
        let number = Double(self.review.rating) * 0.5
        return Int(number)
    }
    
    func image(for number: Int) -> Image {
        if number > rate() {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}


struct ReviewsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel


    @Binding var movie: Movie
    @StateObject var dataSource = ContentDataSourceReviews()

    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        VStack {
            if(dataSource.totalElements == 0) {
                EmptyView()
            }
            else {
                
                VStack(alignment: .leading, content: {
                    
                    HStack {
                        Text("Reviews").font(.subheadline).bold()
                        
                    }
                })
                .frame(width: (UIScreen.main.bounds.width), height: 40)
                .background(Color(.systemGray6))
                .foregroundColor(Color.blue)

                
                
                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
   
                    ScrollView{
                        LazyVStack {
                            ForEach(dataSource.items, id: \.id) { review in
                                if(dataSource.items.last == review){
                                    ReviewRow(review: review)
                                        .frame(width: width, height: 170)

                                        .onAppear {
                                            print("Load More")
                                            dataSource.loadMoreContent(user: user, movie: movie)
                                        }
                                }
                                else {
                                    ReviewRow(review: review)
                                        .frame(width: width, height: 170)

                                    Divider()
                                }
                                
                            }
                            
                        }
                        
                        if dataSource.isLoadingPage {
                            ProgressView() //A view that shows the progress towards completion of a task.
                        }
                        
                   }

                }
                else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack {
                            ForEach(dataSource.items, id: \.id) { review in
                                if(dataSource.items.last == review){
                                    ReviewRow(review: review)
                                        .frame(width: 400, height: 200)

                                        .onAppear {
                                            print("Load More")
                                            dataSource.loadMoreContent(user: user, movie: movie)
                                        }
                                }
                                else {
                                    ReviewRow(review: review)
                                        .frame(width: 400, height: 200)

                                    Divider()
                                }
                                
                            }
                        }
                        .padding(.leading, 15)
                        
                        Spacer()
                    }

                }
                else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack {
                            ForEach(dataSource.items, id: \.id) { review in
                                if(dataSource.items.last == review){
                                    ReviewRow(review: review)
                                        .frame(width: 400, height: 200)

                                        .onAppear {
                                            print("Load More")
                                            dataSource.loadMoreContent(user: user, movie: movie)
                                        }
                                }
                                else {
                                    ReviewRow(review: review)
                                        .frame(width: 400, height: 200)

                                    Divider()
                                }
                                
                            }
                        }
                        .padding(.leading, 15)
                        Spacer()
                    }
                    
                }
                
            }
            
        }
        .onAppear {
            dataSource.loadMoreContent(user: user, movie: movie)
        }
        .frame(width: UIScreen.main.bounds.width)

    }
    
}

struct DropDownMovie: View {
    @Binding var movie: Movie

    @State var expand = false
    
    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        VStack {
            VStack(alignment: .leading, content: {
                
                HStack {
                    Text("More Details").font(.subheadline).bold()
                    
                    Image(systemName: expand ? "chevron.up" : "chevron.down")
                        .font(.system(size: 20))
                }
            })
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)
            .onTapGesture {
                self.expand.toggle()
            }

            
            if expand {
                VStack{
                    if let unwrapped = movie.language {
                        
                        Group {
                            Text("Language(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                    if let unwrapped = movie.writer {
                        
                        Group {
                            Text("Writer(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.awards {

                        Group {
                            Text("Awards(s): ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                    if let unwrapped = movie.boxOffice {
                        
                        Group {
                            Text("Box Office: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.production {
                        
                        Group {
                            Text("Production: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()

                    }
                    
                    if let unwrapped = movie.country {
                        
                        Group {
                            Text("Country: ").bold() + Text(unwrapped)
                        }
                        .padding(.bottom, 10)
                        .frame(width: width, alignment: .topLeading)

                        Divider()
                    }
                    
                }.padding(.top, 10)
                    
            }
        }.frame(width: UIScreen.main.bounds.width)

    }
    
}

//Modified From: https://www.hackingwithswift.com/books/ios-swiftui/adding-a-custom-star-rating-component
struct RatingRow: View {
    @Binding var movie: Movie
    
    var maximumRating = 5

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    
    var offColor = Color.gray
    var onColor = Color.yellow
    
    
    var body: some View {
        HStack {

            ForEach(1..<maximumRating + 1) { number in
                self.image(for: number)
                    .foregroundColor(number > rate() ? self.offColor : self.onColor)
            }
            
            Text(numVotes())
                .font(.system(size: 15.0)).bold()
                .foregroundColor(.white).shadow(radius: 5)
            
        }
    }
    
    func rate() -> Int {
        //double five_star_rating = float_rating * .5;
        //double rounded = (double) Math.round(five_star_rating * 100) / 100;
        
        if let unwrapped = self.movie.ratings {
            
            let number = unwrapped.rating! * 0.5
            return Int(number)
        } else {
            return 0
        }
    }
    
    func numberFormat(number: Int) -> String  {
        if(number < 1000) {
            return String(number)
        }
        let x = log(Double(number))
        let y = log(1000.0)
        let exp = Int(x/y)
        let z = pow(1000,exp)
        let v = Decimal(number)/z
        
        let lst = ["K","M","G","T","P"]
        
        return String(format: "%.1f \(lst[exp-1])", Float(truncating: v as NSNumber))
    }
    
    func numVotes() -> String {
        
        if let unwrapped = self.movie.ratings {
            
            let number = Int(unwrapped.numVotes!)
            let num_format = numberFormat(number: number)
            
            return "(\(num_format))"
            
        } else {
            return ""
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rate() {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

struct GenreRow: View {
    @Binding var movie: Movie
    @State var isLinkActive = false    
    
    var body: some View {
        VStack {
            HStack {
                ForEach(movie.genres, id: \.name) { genre in
                        VStack{
                            NavigationLink(destination: GenreView(genre: genre)){
                                Text(genre.name)
                                    .padding(7)
                                    .font(.system(size: 25, design: .default))
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .frame(height: 50)
                            }
                        }
                   }
            }
        }
    }
}


struct CastRowiPad: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    @Binding var movie: Movie
    
    let rowHeight = 65
    let width = (UIScreen.main.bounds.width-33)

    var body: some View {
        VStack {
            HStack {
                Text("Cast & Crew").font(.subheadline).bold()
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)


            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 25) {
                    ForEach(movie.cast, id: \.starId) { cast in
                        let c = CastDecode(cast: cast)
                    
                        NavigationLink(destination: CastView(cast: cast)) {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Color(.systemGray6))
                                        .frame(width: 100, height: 145)

                                    
                                    WebImage(url: URL(string: c.photo()))
                                            .resizable()
                                            .renderingMode(.original)
                                            .placeholder(Image(systemName: "person"))
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(8)
                                            .frame(width: 100, height: 145)

                                }
                                .frame(width: 100, height: 145)
                                
                                Text(c.name())
                                        .foregroundColor(Color.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)

                                Text(c.subStringCast())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                
                            }.frame(width: 100)
                        }
                    
                    }
                    
                }
            }
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
    }
}

struct CastRow: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    @Binding var movie: Movie
    
    let rowHeight = 65
    let width = (UIScreen.main.bounds.width-33)

    var body: some View {
        VStack {
            HStack {
                Text("Cast & Crew").font(.subheadline).bold()
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)

            ForEach(movie.cast, id: \.starId) { cast in
                let c = CastDecode(cast: cast)
            
                VStack {
                    NavigationLink(destination: CastView(cast: cast)) {
                        HStack {
                            VStack {
                                WebImage(url: URL(string: c.photo()))
                                        .resizable()
                                        .renderingMode(.original)
                                        .placeholder(Image(systemName: "person"))
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(8)
                                
                            }
                            .frame(width: 35, height: 70)
                            
                            VStack(alignment: .leading) {
                                
                                Text(c.name())
                                    .foregroundColor(Color.blue)

                                Text(c.subStringCast()).font(.subheadline).foregroundColor(.gray)

                            }
                            Spacer()
                            Text("Details")
                                .foregroundColor(Color.blue)
                            
                            Image(systemName: "chevron.right")
                                .font(Font.system(size: 15))
                                .foregroundColor(Color.gray)

                        }
                    }
                                        
                }
                .frame(height: CGFloat(rowHeight))
                .padding(.leading, 15)
                .padding(.trailing, 15)
                
                Divider().frame(width: UIScreen.main.bounds.width)
            }
        }
        //.frame(height: CGFloat(rowHeight * movie.cast.count))
        //.frame(height: self.movie.cast.reduce(0) { i, _ in i + CGFloat(rowHeight)})
        .listStyle(PlainListStyle())

        .onAppear(perform: {
            UITableView.appearance().isScrollEnabled = false
        })
            
    }
}



struct BackgroundView: View {
    @EnvironmentObject var user: UserData

    @Binding var movie: Movie
        
    let width = (UIScreen.main.bounds.width)

    var body: some View {
        let m = MovieDecode(movie:movie)
        
        ZStack (alignment: .bottomLeading){
            WebImage(url: URL(string: m.background()))
                    .placeholder(Image(systemName: "livephoto.slash"))
                    .resizable()
                    .frame(width: width, height: 250, alignment: .center)
                    .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text(m.title()).font(.system(size: 25)).bold().foregroundColor(.white).shadow(radius: 5)

                    BookmarkView(movie: $movie)
                }
                
                Text(m.subString()).font(.subheadline).bold().foregroundColor(.white).shadow(radius: 5)
                    .padding(.bottom, 1)

                RatingRow(movie: $movie)

            }
            .padding(.bottom,15)
            .padding(.leading,10)
            
        }
        .frame(width: width, height: 250, alignment: .center)
        
        let reviews = RatingDecode(movie: movie)
        let imdb = reviews.getIMDB()
        let rotten = reviews.getRottenTomatoes()
        let meta = reviews.getMetaCritic()
        
        
        HStack {
            
            imdb.padding(.trailing, 10)
            
            rotten.padding(.trailing, 10)
            
            meta
            
        }.frame(width: width - 33)
    }
}


struct iPhonePortraitMovieView: View {
    @Binding var movie: Movie
    @State var scrollText = false
    
    @State var index = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    
    let width = (UIScreen.main.bounds.width-33)
    
    var body: some View {
        let m = MovieDecode(movie:movie)

        
        VStack {
            
            //if (m.background().isEmpty) {
            if(true) {
                ZStack {
                    WebImage(url: URL(string: m.background()))
                        .resizable()
                        .placeholder(Image("background"))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width)
                        .blur(radius: 6)

                    VStack (alignment: .leading){
                        Spacer()
                        
                        HStack {
                            
                            Spacer()
                            
                            //ZStack(alignment: .topleading)
                            VStack {
                                WebImage(url: m.posterURL())
                                    .resizable()
                                    //.renderingMode(.original)
                                    .placeholder(Image("no_image"))
                                    //.aspectRatio(contentMode: .fit)
                                    .clipped()
                                    .cornerRadius(8)
                                    .frame(width: 100, height: 150)
                                
                                BookmarkView(movie: $movie)
              
                            }.frame(width: 100)

                            VStack (alignment: .leading){
                                Text(m.title())
                                    .font(.system(size: 30)).bold()
                                    .shadow(radius: 6)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.1)
                                    .padding(.bottom,2)
                                    //.frame(width: .infinity, alignment: .leading)
                                
                                Text(m.subString())
                                    .font(.system(size: 15.0)).bold()
                                    .shadow(radius: 5)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .padding(.bottom,2)
                                

                                RatingRow(movie: $movie)
                                
                                HStack {
                                    //ScrollView(.horizontal) {
                                        let reviews = RatingDecode(movie: movie)
                                        let imdb = reviews.getIMDB()
                                        let rotten = reviews.getRottenTomatoes()
                                        let meta = reviews.getMetaCrticRow()
                                        
                                    Group {
                                        if(index == 0) {
                                            imdb
                                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))

                                        }
                                    
                                        else if(index == 1) {
                                            rotten
                                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))


                                        }
                                        
                                        else {
                                            meta
                                                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 1.0)))

                                        }
                                        
                                    }
                                    .onReceive(timer) { _ in
                                        if(index == 2) {
                                            self.index = 0
                                        }
                                        else {
                                            self.index += 1
                                        }
                                    }
                                    
                                    Spacer()

                                }.frame(height: 25)

                                Spacer()
                                
                            }
                            .padding(.leading, 2)
                            .frame(width: UIScreen.main.bounds.width-150, height: 180)
                            
                            Spacer()
                            
                        }.frame(width: UIScreen.main.bounds.width)
                        
                        Spacer()
                        
                    }.frame(width: UIScreen.main.bounds.width, height: 180, alignment: .leading)
   
                }
                .frame(width: UIScreen.main.bounds.width)
                
                VStack {
                    Text(m.plot())
                        .font(.system(size: 15.0)).bold()
                        .shadow(radius: 5)
                        .minimumScaleFactor(0.1)
                    
                    GenreRow(movie: $movie)
            
                }.frame(width:width)
            }
            else {
                
                BackgroundView(movie: $movie)
                
                VStack {

                    Text(m.plot())
                        .padding(.bottom,5)
                                
                }.frame(width:width)
                
            }
        }
    }
}

struct iPhoneLandscapeMovieView: View {
    @Binding var movie: Movie
    
    let width = (UIScreen.main.bounds.width)
    
    var body: some View {
        let m = MovieDecode(movie:movie)
        VStack {
                
            HStack{
                WebImage(url: m.posterURL())
                    .resizable()
                    .renderingMode(.original)
                    .placeholder(Image("no_image"))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(width: 160, height: 220)
                
                VStack (alignment: .leading){
                    Text(m.title()).font(.title)
                    
                    Text(m.subString()).font(.subheadline).foregroundColor(.gray)
                    
                    Text(m.director())

                    HStack {
                        let reviews = RatingDecode(movie: movie)
                        let imdb = reviews.getIMDB()
                        let rotten = reviews.getRottenTomatoes()
                        let meta = reviews.getMetaCritic()
                        
                        BookmarkView(movie: $movie)
                            .padding(.trailing, 10)
                        
                        imdb.padding(.trailing, 10)
                        
                        rotten.padding(.trailing, 10)
                        
                        meta
                    }

                    Text(m.plot())
                                
                }
                
            }
            .frame(width: width, height: 200)
            
        }
    }
}

struct iPadMovieView: View {
    @Binding var movie: Movie
    @EnvironmentObject var user: UserData
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        let m = MovieDecode(movie:movie)

    
        //if (m.background().isEmpty) {
        //Disabled - Background looks better
        if (false) {
            HStack(alignment: .top){
                WebImage(url: URL(string: m.poster()))
                    .resizable()
                    .renderingMode(.original)
                    .placeholder(Image("no_image"))
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .frame(width: 290, height: 400)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(m.title())
                            .font(.system(size: 35))
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)

                        BookmarkView(movie: $movie)
                        
                        Spacer()
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)   // << here !!
                    .padding(.bottom,5)


                    Text(m.subString())
                        .font(.system(size: 20.0)).bold()
                        .foregroundColor(.gray)
                        .padding(.bottom,5)
                        .frame(maxWidth: .infinity, alignment: .leading)   // << here !!

                                  
                    RatingRow(movie:$movie)
                        .padding(.bottom,5)
                        .frame(maxWidth: .infinity, alignment: .leading)   // << here !!

                    
                    HStack {
                        let reviews = RatingDecode(movie: movie)
                        let imdb = reviews.getIMDB()
                        let rotten = reviews.getRottenTomatoes()
                        let meta = reviews.getMetaCritic()
                                            
                        
                        rotten.padding(.trailing, 10)
                        imdb.padding(.trailing, 10)
                        meta
                
                    }.frame(height: 50)
                    
                    
                    Text(m.plot())
                        .font(.system(size: 20.0))
                        .padding(.bottom,5)
                        .frame(height: 155, alignment: .topLeading)
                    
                    GenreRow(movie: $movie)
                    
                }.frame(width: (UIScreen.main.bounds.width-350))
            }
        }
        else {
            
            let reviews = RatingDecode(movie: movie)
            let imdb = reviews.getIMDB()
            let rotten = reviews.getRottenTomatoes()
            let meta = reviews.getMetaCrticRow()
            
            ZStack (alignment: .bottomLeading){
                WebImage(url: URL(string: m.background()))
                        .resizable()
                        .placeholder(Image("background"))
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: 400)
                        .clipped() // Equal to clipsToBounds = true
                        .blur(radius:  6)

                VStack(alignment: .center) {
                    
                    Spacer()
                    
                    HStack {
                        WebImage(url: m.posterURL())
                            .resizable()
                            .renderingMode(.original)
                            .placeholder(Image("no_image"))
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .frame(width: 190, height: 265)
                        
                        
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(m.title()).font(.system(size: 35)).bold().foregroundColor(.white).shadow(radius: 5)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)

                                BookmarkView(movie: $movie)
                            }
                            
                            Text(m.subString()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                                .padding(.bottom, 1)

                            RatingRow(movie: $movie).padding(.bottom, 1)
                            
                            Text(m.plot()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                                .padding(.bottom, 1)
                            
                            HStack {
                                imdb
                                meta
                                rotten
                            }
                            GenreRow(movie: $movie)

                        }
                        .frame(width: 580)
                        
                    }
                    
                    Spacer()
                    
                }.frame(width: UIScreen.main.bounds.width)


                
            }
            .frame(width: width, height: 400, alignment: .center)
            
        }
    
    }
}

struct MovieView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @EnvironmentObject var viewPopover: PopoverViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @State var movie: Movie
    @State private var addedToCartAlert = false

    let height = (UIScreen.main.bounds.height)
    let width = (UIScreen.main.bounds.height)
    
    var body: some View {
        
        ZStack {
            GeometryReader {geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                      if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                          iPhonePortraitMovieView(movie: $movie)
                          //GenreRow(movie: $movie)
                          DropDownMovie(movie: $movie)
                          CastRow(movie: $movie)
                          ReviewsView(movie: $movie)

                      }
                      else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                          
                          iPhoneLandscapeMovieView(movie: $movie)
                          GenreRow(movie: $movie)
                              .padding(.bottom, 5)

                          DropDownMovie(movie: $movie)
                          CastRowiPad(movie: $movie)
                          ReviewsView(movie: $movie)

                      }
                      else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                          iPadMovieView(movie: $movie)
                          DropDownMovie(movie: $movie)
                          CastRowiPad(movie: $movie)
                          ReviewsView(movie: $movie)

                      }
                      
                        VStack {
                            //Blank Space for Scroll View and ZStack Button
                        }.frame(height: 50)
                    }
                    
                ZStack{

                    Button(action: {
                        print("Add button pressed...")
                        self.addCartData(movieId: movie.id, qty: 1)
                    })
                    {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                                .font(.title)
                            Text("Add to Bag")
                                .fontWeight(.semibold)
                                .font(.title)
                        }
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)

                   }.offset( x:(geometry.size.width/2)-100, y: geometry.size.height-70)
                }
                .onAppear(perform: {
                    self.getMovieData()
               })

            }
            .toast(isPresenting: $addedToCartAlert){
                AlertToast(type: .complete(Color.green), title: "Added To Cart")
            }
            
            .toast(isPresenting: $viewModel.show){
                //Choose .hud to toast alert from the top of the screen
                AlertToast(displayMode: .hud, type: .error(Color.red), title: viewModel.title, subTitle: viewModel.subtitle)
            }
            
        }
        
        .popup(isPresented: $viewPopover.show, type: .toast, position: .bottom) {
            
            ZStack {
                Color(.systemGray6)
                    .cornerRadius(40, corners: [.topLeft, .topRight])
                    //.frame(width: UIScreen.main.bounds.width, height: 500)
                    //.cornerRadius(80, corners: [.topLeft, .topRight])
                
                VStack {
                    Color.white
                        .frame(width: 72, height: 6)
                        .clipShape(Capsule())
                        .padding(.top, 15)
                        .padding(.bottom, 10)



                    if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                        ScrollView {
                            Text(viewPopover.text)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                        }
                        .padding(.bottom, 30)
                        .frame(height: UIScreen.main.bounds.height - 250)

                    }
                    else {
                        ScrollView {
                            Text(viewPopover.text)
                                .padding(.leading, 15)
                                .padding(.trailing, 15)
                        }
                        .padding(.bottom, 30)
                        .frame(height: UIScreen.main.bounds.height - 105)
                    }

                }
                
            }  .fixedSize(horizontal: false, vertical: true)

            
            
        }
        
       .navigationBarHidden(false)
       .navigationBarTitle(Text("\(movie.title)"), displayMode: .inline)
       .toolbar {
           ToolbarItemGroup(placement: .bottomBar) {
               ItemsToolbar()
           }
       }
    }
    
    func addCartData(movieId: String, qty: Int) {
        API(user: user).addCart(movieId: movieId, qty: qty){ (result) in
            switch result {
            case .success( _ ):
                DispatchQueue.main.async {
                    addedToCartAlert = true
                    self.getCartQtyData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.subtitle = error.localizedDescription
                    viewModel.show = true
                }
            }
        }
    }

    func getMovieData() {
        API(user: user).getMovie(id: movie.id) { (result) in
            switch result {
            case .success(let movie):
                DispatchQueue.main.async {
                    self.movie = movie
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.subtitle = error.localizedDescription
                    viewModel.show = true
                    
                }
            }
        }
    }
    
    func getCartQtyData() {
        API(user: user).getCartQty(){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    user.qty = qty
                }
            case .failure(let error):
                viewModel.subtitle = error.localizedDescription
                viewModel.show = true
            }
        }
    }
    
}

