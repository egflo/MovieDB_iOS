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
import StripeCore




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
    @EnvironmentObject var viewModel: AlertViewModel

    @State var movie: Movie
    @State var bookmark: BookmarkResponse?

    var body: some View {
        VStack {
            
            if let bookmark = bookmark {
                
                Button(action: {
                    print("Bookmark button pressed...")
                    updateBookmark()
                    
                })
                {
                    Image(systemName:(bookmark.success) ? "minus.circle" : "plus.circle")
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
        let URL = "\(MyVariables.API_IP)/bookmark/\(movie.id)"
        NetworkManager.shared.getRequest(of: BookmarkResponse.self, url: URL){ (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    bookmark = response
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateBookmark() {
        NetworkManager.shared.updateBookmark(id: movie.id, userId: user.id) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    //self.bookmark = bookmark
                    viewModel.setComplete(title: "Bookmark Updated", subtitle: response.message)
                    getBookmarkData()
                }
            case .failure(let error):
                viewModel.setError(title: "Bookmark Error", subtitle: error.localizedDescription)

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

                Text("By \(review.customer.firstname)")
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


    @State var movie: Movie
    @StateObject var dataSource = ContentDataSourceTest<Review>()

    let width = (UIScreen.main.bounds.width - 33)

    var body: some View {
        VStack {
            if(dataSource.items.count == 0) {
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
                                    ReviewRow(review: review)
                                        .frame(width: width, height: 170)
                                        .onAppear(perform: {
                                            if !self.dataSource.endOfList {
                                                if self.dataSource.shouldLoadMore(item: review) {
                                                    self.dataSource.fetch(path: "review/movie/\(movie.id)")
                                                }
                                            }
                                        })
                                
                            }
                            
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
                                        .onAppear(perform: {
                                            if !self.dataSource.endOfList {
                                                if self.dataSource.shouldLoadMore(item: review) {
                                                    self.dataSource.fetch(path: "review/movie/\(movie.id)")
                                                }
                                            }
                                        })
                 
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
                                ReviewRow(review: review)
                                    .frame(width: 400, height: 200)
                                    .onAppear(perform: {
                                        if !self.dataSource.endOfList {
                                            if self.dataSource.shouldLoadMore(item: review) {
                                                self.dataSource.fetch(path: "review/movie/\(movie.id)")
                                            }
                                        }
                                    })

                            }
                        }
                        .padding(.leading, 15)
                        Spacer()
                    }
                    
                }
                
            }
            
        }
        .onAppear {
            self.dataSource.fetch(path: "review/movie/\(movie.id)")
        }
        .frame(width: UIScreen.main.bounds.width)

    }
    
}

struct DropDownMovie: View {
    @State var movie: Movie
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
        }
        .frame(width: UIScreen.main.bounds.width)
        .animation(.spring())
    }
}

//Modified From: https://www.hackingwithswift.com/books/ios-swiftui/adding-a-custom-star-rating-component
struct RatingRow: View {
    @State var movie: Movie
    
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
    @State var movie: Movie
    @State var isLinkActive = false    
    
    var body: some View {
        VStack {
            HStack {
                ForEach(movie.genres!, id: \.name) { genre in
                        VStack{
                            NavigationLink(destination: GenreView(genre: genre)){
                                Text(genre.name)
                                    .padding(.leading,5)
                                    .padding(.trailing,5)
                                    .padding(.top, 2)
                                    .padding(.bottom,2)
                                    .font(.system(size: 20, design: .default))
                                    .foregroundColor(.white)
                                    .background(Capsule().fill(Color.blue))
                                    //.padding(7)
                                    //.font(.system(size: 25, design: .default))
                                    //.foregroundColor(.white)
                                   // .background(Color.blue)
                                   // .cornerRadius(8)
                                   // .frame(height: 50)
                            }
                        }
                   }
            }
        }
    }
}


struct CastRowiPad: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    @State var movie: Movie
    
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
                    ForEach(movie.cast!, id: \.starId) { cast in
                        let c = CastDecode(cast: cast)
                    
                        NavigationLink(destination: CastView(castId: cast.starId)) {
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
            .padding(.bottom, 5)
            .padding(.leading, 15)
            .padding(.trailing, 15)
        }
    }
}

struct CastRow: View {
    @Environment(\.defaultMinListRowHeight) var minRowHeight

    @State var movie: Movie
    @State var expand = false

    let rowHeight = 65
    let width = (UIScreen.main.bounds.width-33)

    var body: some View {
        VStack {
            HStack {
                Text("Cast & Crew").font(.subheadline).bold()
                
                Image(systemName: expand ? "chevron.up" : "chevron.down")
                    .font(.system(size: 20))
            }
            .frame(width: (UIScreen.main.bounds.width), height: 40)
            .background(Color(.systemGray6))
            .foregroundColor(Color.blue)
            .onTapGesture {
                self.expand.toggle()
            }
            
            if(expand) {
                VStack {
                    
                    if let cast = movie.cast {
                        
                        ForEach(cast, id: \.starId) { cast in
                            let c = CastDecode(cast: cast)
                        
                            VStack {
                                NavigationLink(destination: CastView(castId: cast.starId)) {
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
                    else {
                        
                        ProgressView()
                    }
                }
                
                .listStyle(PlainListStyle())
                .onAppear(perform: {
                    UITableView.appearance().isScrollEnabled = false
                })
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .animation(.spring())
        
        //.frame(height: CGFloat(rowHeight * movie.cast.count))
        //.frame(height: self.movie.cast.reduce(0) { i, _ in i + CGFloat(rowHeight)})
    }
}



struct BackgroundView: View {
    @EnvironmentObject var user: UserData

    @State var movie: Movie
        
    let width = (UIScreen.main.bounds.width)

    var body: some View {
        let m = MovieDecode(movie:movie)
        
        VStack {
            ZStack (alignment: .bottomLeading){
                WebImage(url: URL(string: m.background()))
                        //.placeholder(Image(systemName: "livephoto.slash"))
                        .placeholder(Image("background"))
                        .resizable()
                        .frame(width: width, height: 250, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        //.blur(radius:  6)
                
                VStack {
                                        
                    WebImage(url: m.posterURL())
                        .resizable()
                        //.renderingMode(.original)
                        .placeholder(Image("no_image"))
                        //.aspectRatio(contentMode: .fit)
                        .clipped()
                        .cornerRadius(8)
                        .frame(width: 125, height: 180)
                        //.padding(.top, 10)
                    
                    HStack {
                        
                        Spacer()
                        
                        HStack {
                            VStack(spacing:2) {
                                Spacer()
                                BookmarkView(movie: movie)
                                Text("My List").font(.system(size: 12)).bold()
                                Spacer()

                            }
                            
                            VStack(spacing:2) {
                                Spacer()
                                RateView(movie: movie)
                                Text("Rate").font(.system(size: 12)).bold()
                                Spacer()
                            }
                            
                            Divider()
                            
                            if let ratings = movie.ratings {
                                
                                if let unwrapped = ratings.rating {
                                    VStack(spacing:2) {
                                        Spacer()
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 25.0))
                                            .foregroundColor(Color.yellow)
                                        let rating = String(format: "%.1f", unwrapped)
                                        Group{Text("\(rating)").font(.system(size: 14)).bold() + Text("/10").font(.system(size: 10)).bold().foregroundColor(.gray)}
                                        Spacer()
                                    }
                                }

                                if let unwrapped = ratings.metacritic {
                                    
                                    VStack(spacing:2) {
                                        Spacer()
                                        

                                        VStack(alignment: .leading) {
                                            let s = String(format: "%.0f", Double(unwrapped) ?? 0)
                                            Text(s).font(.system(size: 14)).bold()
                                                .foregroundColor(Color.white)
                                                .background(Rectangle()
                                                .fill(meta(score: unwrapped))
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(4))
                                            
                                        }.frame(width: 30, height: 30)
                                        
                                        Text("Metascore").font(.system(size: 12)).bold()
                                        Spacer()

                                    }


                                }
                                
                                if let unwrapped = ratings.imdb {
                                    VStack(spacing:2) {
                                        Spacer()

                                        Group{Text(unwrapped).font(.system(size: 14)).bold() + Text("/10").font(.system(size: 10)).bold().foregroundColor(.gray)}
                                        
                                        Image("imdb")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 25)
                                        
                                        Spacer()

                                    }

                                }
                                
                                if let unwrapped = ratings.rottenTomatoes {
                                    VStack(spacing:2) {
                                        
                                        Spacer()

                                        Text("\(unwrapped)%").font(.system(size: 14)).bold()
                                                                                
                                        Image(ratings.rottenTomatoesStatus ?? "Fresh")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                        
                                        Spacer()

                                        
                                    }

                                }
                                
                                if let unwrapped = ratings.rottenTomatoesAudience {
                                    VStack(spacing:2) {
                                        
                                        Text("\(unwrapped)%").font(.system(size: 14)).bold()
                                        
                                        Image(movie.ratings!.rottenTomatoesAudienceStatus ?? "Upright")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 25, height: 25)
                                        
                                    }

                                }
                                
                                
                            }
                            
                            else {
                                ProgressView()
                            }
                            
                                     
                        }
                        .frame(height: 60)
                        .padding(.leading,8)
                        .padding(.trailing, 8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray6)))
                        
                        Spacer()
                    }
                    
                }
                .frame(height: 240)
                .offset(y:25)
                
            }
            //.border(Color.yellow)
            
            Spacer()
            
        }.frame(height: 290)
           // .border(Color.red)

    }
    
    func meta(score: String) -> Color {
        
        let number = Double(score) ?? 0
        var color = Color.gray
        
        if(number >= 61){
            color = Color.green
        }
        else if(number >= 40 && number <= 60){
            color = Color.yellow
        }
        else if(number >= 20 && number <= 39){
            color = Color.red
        }
        else {
            color = Color.gray
        }
    
        return color
        
    }
}


struct iPhonePortraitMovieView: View {
    @State var movie: Movie
    @State var scrollText = false
    
    @State var index = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    
    let width = (UIScreen.main.bounds.width-33)
    
    var body: some View {
        let m = MovieDecode(movie:movie)

        VStack {
            
            BackgroundView(movie: movie)
            
            VStack(alignment:.leading) {
                
                Text(m.title())
                    .font(.system(size: 30)).bold()
                    .padding(.bottom,5)
                
                m.inventoryStatus()
                    .padding(.bottom,5)


                Text(m.subString())
                    .padding(.bottom,5)
                
                VStack {
                    HStack {
                        if let genres = movie.genres {
                            
                            ForEach(genres, id: \.name) { genre in
                                    VStack{
                                        NavigationLink(destination: GenreView(genre: genre)){
                                            Text(genre.name)
                                                .padding(.leading,4)
                                                .padding(.trailing,4)
                                                .padding(.top, 2)
                                                .padding(.bottom,2)
                                                .font(.system(size: 17, design: .default))
                                                .foregroundColor(.white)
                                                .background(Capsule().fill(Color.blue))
                                        }
                                    }
                               }
                            
                        }
                        else {
                            ProgressView()
                        }

                    }
                }
                
                Text(m.plot())
                    .padding(.bottom,10)
                            
            }.frame(width:width)
                
        }
    }
}


struct RatingIcon: View {
    var filled: Bool = false

    var body: some View {
        Image(systemName: filled ? "star.fill" : "star")
            .foregroundColor(filled ? Color.yellow : Color.white.opacity(0.6))
    }
}


struct RateView: View {
    @State var movie: Movie
    @State var popupOpen:Bool = false
    @State var stars:Int = 0
    
    var drag: some Gesture {
        return DragGesture(minimumDistance: 0, coordinateSpace: .local)
        .onChanged({ val in
            let percent = max((val.location.x / 110.0), 0.0)
            self.stars = min(Int(percent * 5.0) + 1, 5)        })
        .onEnded { val in
            let percent = max((val.location.x / 110.0), 0.0)
            self.stars = min(Int(percent * 5.0) + 1, 5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    self.popupOpen = false
                }
            }
        }
    }
    
    var body: some View {
        
        Button(action: {
            withAnimation { self.popupOpen = !self.popupOpen }
            }) {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "star")
                    .font(.system(size: 25.0))
                    .foregroundColor(Color.blue)
            }
                
        }.overlay(
            HStack(alignment: .center, spacing: 4) {
                RatingIcon(filled: stars > 0)
                RatingIcon(filled: stars > 1)
                RatingIcon(filled: stars > 2)
                RatingIcon(filled: stars > 3)
                RatingIcon(filled: stars > 4)
                
            }
            .gesture(drag)
            .padding(.all, 12)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 0)
            .offset(x: 0, y: 40) // Move the view above the button
            .opacity(popupOpen ? 1.0 : 0)
         )
    }

}



struct iPadMovieView: View {
    @State var movie: Movie
    @EnvironmentObject var user: UserData
    
    let width = UIScreen.main.bounds.width
    
    var body: some View {
        let m = MovieDecode(movie:movie)
    
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
                                
                HStack {
                    VStack {
                        
                        WebImage(url: m.posterURL())
                            .resizable()
                            .renderingMode(.original)
                            .placeholder(Image("no_image"))
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .frame(width: 190, height: 265)
                        
                        HStack {
                            
                            BookmarkView(movie: movie)
                            RateView(movie: movie)
                            
                        }
                        .padding(.leading,5)
                        .padding(.trailing,5)
                        .padding(.top,2)
                        .padding(.bottom,2)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(UIColor.systemGray6)))
                        
                    }.padding(.top, 50)
                       // .border(Color.pink)

                    
                    VStack(alignment: .leading) {
                        
                        Spacer()
                        
                        HStack {
                            Text(m.title()).font(.system(size: 35)).bold().foregroundColor(.white).shadow(radius: 5)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)

                        }
                        .padding(.bottom, 1)
                        
                        m.inventoryStatus()
                            .padding(.bottom,2)
                        
                        Text(m.subString()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                            .padding(.bottom, 1)

                        GenreRow(movie: movie)

                        RatingRow(movie: movie).padding(.bottom, 1)
                        
                        Text(m.plot()).font(.system(size: 15)).bold().foregroundColor(.white).shadow(radius: 5)
                            .padding(.bottom, 1)
                        
                        HStack {
                            imdb
                            meta
                            rotten
                        }
                        
                        Spacer()

                    }
                    .frame(width: 580)
                   // .border(Color.white)
                    
                }
                //.frame(minHeight: 250)
                //.border(Color.red)

                                
            }.frame(width: UIScreen.main.bounds.width)
        }
        .frame(width: width, height: 400, alignment: .center)
            
    }
    
}

struct MovieView: View {
    @EnvironmentObject var user: UserData
    @EnvironmentObject var viewModel: AlertViewModel
    @EnvironmentObject var viewPopover: PopoverViewModel

    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    
    var movieId: String

    @State var movie: Movie?
    @State private var addedToCartAlert = false

    let height = (UIScreen.main.bounds.height)
    let width = (UIScreen.main.bounds.height)
    
    var body: some View {
        
        ZStack {
            GeometryReader {geometry in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack (spacing: 0) {
                            
                            if let movie = movie {
                                if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                                    iPhonePortraitMovieView(movie: movie)
                                    DropDownMovie(movie: movie)
                                    Divider()
                                    CastRow(movie: movie)
                                    Divider()
                                    ReviewsView(movie: movie)

                                }
                                else if horizontalSizeClass == .regular && verticalSizeClass == .compact {
                                    
                                    iPhonePortraitMovieView(movie: movie)
                                    GenreRow(movie: movie)
                                        .padding(.bottom, 5)
                                    DropDownMovie(movie: movie)
                                    CastRowiPad(movie: movie)
                                    ReviewsView(movie: movie)

                                }
                                else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                                    iPadMovieView(movie: movie)
                                    DropDownMovie(movie: movie)
                                    Divider()
                                    CastRowiPad(movie: movie)
                                    //Divider()
                                    ReviewsView(movie: movie)

                                }
                            }
                            
                            else {
                                ProgressView()
                            }

                            
                        }
                      
                        VStack {
                            //Blank Space for Scroll View and ZStack Button
                        }.frame(height: 50)
                    }
                    
                ZStack{

                    Button(action: {
                        print("Add button pressed...")
                        self.addCartData(movieId: movieId, qty: 1)
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
       .navigationBarTitle(Text("\(movieId)"), displayMode: .inline)
       .toolbar {
           ToolbarItemGroup(placement: .bottomBar) {
               ItemsToolbar()
           }
       }
    }
    
    func addCartData(movieId: String, qty: Int) {
        NetworkManager.shared.addCart(movieId: movieId, qty: qty){ (result) in
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
                    self.getMovieData()
                }
            }
        }
    }

    func getMovieData() {
        let URL = "\(MyVariables.API_IP)/movie/\(movieId)"
        NetworkManager.shared.getRequest(of: Movie.self, url: URL) { (result) in
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
        let URL = "\(MyVariables.API_IP)/cart/qty/"
        
        NetworkManager.shared.getRequest(of: Int.self, url: URL){ (result) in
            switch result {
            case .success(let qty):
                DispatchQueue.main.async {
                    user.qty = qty
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    viewModel.setError(title: "Cart Error", subtitle: error.localizedDescription)

                }
            }
        }
    }
    
}

