//
//  PodTutorial.swift
//  PODZ
//
//  Created by Nick Miller on 6/14/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import SwiftUI
import Firebase


struct PodTutorial: View {
    @Binding var seenPodTutorial: Bool
    @State var dontShowAgain = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        VStack {
            Spacer()
            Text("What do I do in a Habit Group?")
                .foregroundColor(.white)
                .bold()
                .font(.system(size: 25))
                .padding(.top, 40)
                .padding(.horizontal, 2)
                .padding(.bottom,5)
            ZStack {
                
                GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 1) {
                        Text("Do your commitment")
                            .font(.system(size: 24))
                        Text("for the day")
                            .font(.system(size: 24))
                        
                    }
                    
                    HStack(alignment: .top) {
                    Spacer()
                        HStack(spacing: 0) {
                    Image("runningTransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                    Image("journaling2Transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                    Image("meditatingTransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        }
                    CurvedArrow(number: 1, radius: 50)
                        .offset(x: 0, y: geo.size.height * 3/20)
                        .frame(alignment: .topTrailing)
                    }
                    Spacer()
                }.frame(alignment: .top)
                .offset(x: geo.size.width * 1/10, y: -1 * geo.size.height * 1/40)
                }
                GeometryReader { geo in
               
                    
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()
                    Text("Log your habit")
                        .font(.system(size: 26))
                        .padding(5)
                    Text("LOG HABIT")
                    .fontWeight(.bold)
                    .frame(maxWidth: 175, maxHeight: 40)
                    .foregroundColor(Color.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .padding(5)
                    CurvedArrow(number: 2, radius: 50)
                        .offset(x: geo.size.width * 5/8, y: 0)

                }.offset(x: 0, y: geo.size.height * 6/20)
                }
                
//                Text("Step 3:  Stick to your commitment for 30 days to help them build habit")
//                    .font(.system(size: 20))
//                    .padding(5)
//                Image(systemName: "arrow.down")
//                    .font(.largeTitle)
                GeometryReader { geo in

                    CurvedArrow(number: 3, radius: 50)
                        .offset(x: -1 * geo.size.width * 9/10, y: geo.size.height * 9/20)
                        .rotationEffect(.degrees(30))
                        
                    VStack(alignment: .leading, spacing: 0) {
                        
                    Text("Help keep your ")
                        .font(.system(size: 18))
                        Text("group on track!")
                        .font(.system(size: 18))
                    Image("logo-transparent200x200")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        .padding(5)

                    }.offset(x: geo.size.width * 2/30, y: geo.size.height * 4/9)
                    
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(30)
            .padding(5)


            
            Spacer()


                Button(action: {}, label: {
                    HStack {
                        Text("Don't show again")
                            .foregroundColor(.white)
                            .font(.title3)
                    Image(systemName: dontShowAgain ? "checkmark.square" : "square")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.leading, 15)
                    }.padding()
                })
                
            Button(action: {
                
                seenPodTutorial = true
                if dontShowAgain {
                    currentUserWrapper.dontShowPodTutorialAgain()
                }
                
            }, label: {
                HStack {
                    Text("I got it")
                        .bold()
                        .font(.title)
                        .foregroundColor(.purple)
                        .padding()
                    Image(systemName: "chevron.right")
                        .font(.title)
                        .foregroundColor(.purple)
                        .padding()
                    
                }
                .padding(.horizontal, 15)
                .background(Color.white)
                .cornerRadius(10)
            })
            .padding()
        }
        .background(Color.purple)
        .edgesIgnoringSafeArea(.all)
    }
}
struct CurvedArrow : View {
    let number : Int

    let radius: Int
    
    var body: some View {
        GeometryReader { geo in
        if number == 1 {
                Path { path in

                    path.addRelativeArc(center: CGPoint(x : 0, y : 0), radius: CGFloat(radius), startAngle: Angle(degrees : 270), delta: Angle(degrees : 90))
                    
                        //path.addLine(to: CGPoint(x: 100, y: 200))
                        //path.addLine(to: CGPoint(x: 100, y: 250))
                    path.move(to: CGPoint(x: radius + radius * 2/5, y: -1 * radius * 2/5))
                    path.addLine(to: CGPoint(x: radius, y: radius * 2/5))
                    path.addLine(to: CGPoint(x: radius - radius * 2/5, y: -1 * radius * 2/5))
                        //path.addLine(to: CGPoint(x: 250, y: 200))
                    
                    

                }.stroke(Color.black, lineWidth: 16)
                
            }
        else if number == 2 {
            Path { path in

                path.addRelativeArc(center: CGPoint(x : 0, y : 0), radius: CGFloat(radius), startAngle: Angle(degrees : 0), delta: Angle(degrees : 90))
                
                    //path.addLine(to: CGPoint(x: 100, y: 200))
                    //path.addLine(to: CGPoint(x: 100, y: 250))
                path.move(to: CGPoint(x: radius * 2/5, y: radius * 2/5))
                path.addLine(to: CGPoint(x: -1 * radius * 2/5, y: radius))
                path.addLine(to: CGPoint(x: radius * 2/5, y: radius * 7/5))
                    //path.addLine(to: CGPoint(x: 250, y: 200))
                
                

            }.stroke(Color.black, lineWidth: 16)
        }
        else if number == 3 {
            Path { path in

                path.addRelativeArc(center: CGPoint(x : geo.size.width, y : 0), radius: CGFloat(radius), startAngle: Angle(degrees : 90), delta: Angle(degrees : 90))
                
                    //path.addLine(to: CGPoint(x: 100, y: 200))
                    //path.addLine(to: CGPoint(x: 100, y: 250))
                path.move(to: CGPoint(x: Int(geo.size.width) - radius * 2/5, y: radius * 2/5))
                path.addLine(to: CGPoint(x: Int(geo.size.width) - radius * 5/5, y: -1 * radius * 2/5))
                path.addLine(to: CGPoint(x: Int(geo.size.width) - radius * 7/5, y: radius * 2/5))
                    //path.addLine(to: CGPoint(x: 250, y: 200))
                
                

            }.stroke(Color.black, lineWidth: 16)
        }
        else if number == 4 {
            Path { path in

                path.addRelativeArc(center: CGPoint(x : radius, y : radius), radius: CGFloat(radius), startAngle: Angle(degrees : 180), delta: Angle(degrees : 90))
                

                path.move(to: CGPoint(x: radius * 3/5, y: -1 * radius * 2/5))
                path.addLine(to: CGPoint(x: radius + radius * 2/5, y: 0))
                path.addLine(to: CGPoint(x: radius * 3/5, y: radius * 2/5))
                
                

            }.stroke(Color.black, lineWidth: 18)
        }
        }


    }
}
struct PodTutorial2 : View {
    
    @Binding var seenPodTutorial: Bool
    @State var dontShowAgain = false
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0) {
            GeometryReader { geo in
                VStack(alignment: .center, spacing : 0) {
                    Text("What do I do in a Habit Group?")
                        .foregroundColor(.white)
                        .bold()
                        .font(.system(size: 22))
                        .padding(.top, geo.size.height * 1/13)
                        .padding(.horizontal, 2)
                        .padding(.bottom,4)
                    Spacer()
                    VStack {
                        Spacer()
                        VStack {
                            Text("Do your habit at the same time each day")
                                .font(.system(size: 19))
                            HStack(spacing: 0) {
                        Image("runningTransparent")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 60, maxHeight: 100)
                        Image("journaling2Transparent")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 60, maxHeight: 100)
                        Image("meditatingTransparent")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 60, maxHeight: 100)                    }
                        }
                        VStack(spacing: 0) {
                                Spacer()
                                Image(systemName: "arrow.down")
                                    .font(.title)
                                Spacer()
                            }
                    VStack {
                        Text("Log your habit in the group")
                            .font(.system(size: 19))
                        Text("LOG HABIT")
                        .fontWeight(.bold)
                        .frame(maxWidth: 175, maxHeight: 40)
                        .foregroundColor(Color.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(5)
                    }
                    VStack(spacing: 0) {
                            Spacer()
                            Image(systemName: "arrow.down")
                                .font(.title)
                            Spacer()
                        }
                    VStack {
                        Text("Help keep your groupmates on track!")
                            .font(.system(size: 19))
                        Image("logo-transparent200x200")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 70, maxHeight: 100)
                            .padding(5)
                        }
                    Spacer()
                    }
                    .padding(.horizontal, 3)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 15)
                    .frame(alignment: .center)

                    VStack {
                        Button(action: {dontShowAgain.toggle()}, label: {
                            HStack {
                                Text("Don't show again")
                                    .foregroundColor(.white)
                            Image(systemName: dontShowAgain ? "checkmark.square" : "square")
                                .foregroundColor(.white)
                                .font(.title3)
                                .padding(.leading, 5)
                            }
                        })
                        Button(action: {
                            
                            seenPodTutorial = true
                            if dontShowAgain {
                                currentUserWrapper.dontShowPodTutorialAgain()
                            }
                        }, label: {
                            HStack {
                                Text("I got it")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .padding(5)
                                Image(systemName: "chevron.right")
                                    .font(.title)
                                    .foregroundColor(.purple)
                                    .padding(5)
                            }
                            .padding(.horizontal, 15)
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(10)
                        })
                    }
                    .padding()
                    .padding(.bottom, geo.size.height * 1/18)
                }.frame(maxWidth: .infinity, alignment: .center)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.purple)
        .edgesIgnoringSafeArea(.all)
        
        
    }
}
struct PodTutorial_Previews: PreviewProvider {
    static var previews: some View {
        PodTutorial2(seenPodTutorial: .constant(true))
        //CurvedArrow(number: 1)
    }
}
