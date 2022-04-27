//
//  LogoLoaderView.swift
//  PODZ
//
//  Created by Nick Miller on 7/15/21.
//  Copyright © 2021 Nick Miller. All rights reserved.
//

import SwiftUI

struct LogoSpinnerLoaderView: View {
    @State var degreesRotation = 0
    @Binding var finishLogoSpinner: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper

    var body: some View {
        Image("logo-transparent200x200")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 12/80 + (currentUserWrapper.differentDevice == .old ? 20 : 0))
            .rotationEffect(.degrees(Double(degreesRotation)))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    degreesRotation = degreesRotation + 360
                }
            }
            .onChange(of: currentUserWrapper.triedToLoadUser, perform: { value in
              finishLogoSpinner = true
            })
            
//            .rotation3DEffect(.degrees(45), axis: (x: 1, y: 0, z: 0))
            
    }

}

struct LogoBounceLoaderView: View {
    @State var bounceDistance: CGFloat = 10
    @State var shadowEllipseSize: CGFloat = 1
    @Binding var finishLogoBounce: Bool
    @EnvironmentObject var currentUserWrapper: UserWrapper
    
    var body: some View {
        VStack(spacing : 0) {
            Image("logo-transparent200x200")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: UIScreen.main.bounds.height * 12/80 + (currentUserWrapper.differentDevice == .old ? 20 : 0))
                .offset(x: 0, y: bounceDistance)
                .zIndex(1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true))//.repeatForever(autoreverses: true))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       bounceDistance = bounceDistance - 100
                    }
                }
                
            Color.black.clipShape(Ellipse())
                .opacity(0.2 + Double(shadowEllipseSize) * 0.1)
                .frame(width: UIScreen.main.bounds.height * 1/15 * shadowEllipseSize + 25, height: UIScreen.main.bounds.height * 1/100 * shadowEllipseSize + 15)
                .zIndex(0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                       shadowEllipseSize = 0
                    }
                }
            
        }.onChange(of: currentUserWrapper.triedToLoadUser, perform: { value in
            finishLogoBounce = true
        })
    }
}
struct LogoScaleLoaderView: View {
    
    @EnvironmentObject var currentUserWrapper: UserWrapper
    @Binding var finishLogoScaleLoaderView: Bool
//    @State var test = false
    
    var body: some View {
        Image("logo-transparent200x200")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: UIScreen.main.bounds.height * 12/80 + (currentUserWrapper.differentDevice == .old ? 20 : 0))
            .scaleEffect(!currentUserWrapper.triedToLoadUser ? 1 : 6)
            .animation(.easeInOut(duration: 0.6))
            .onChange(of: currentUserWrapper.triedToLoadUser, perform: { value in
                print("currentUserWrapper.triedToLoadUser = ", value)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   finishLogoScaleLoaderView = true
                    print("finishLogoScaleLoaderView = true")
                }
            })
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                   finishLogoScaleLoaderView = true
//                }
//            }

    }
}


struct LogoLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        //LogoBounceLoaderView(finishLogoBounce: .constant(false))
        LogoScaleLoaderView(finishLogoScaleLoaderView: .constant(false))
        
    }
}
