//
//  MessagingTextField.swift
//  PODZ
//
//  Created by Nick Miller on 10/12/20.
//  Copyright © 2020 Nick Miller. All rights reserved.
//

import SwiftUI
import Combine






struct MessagingTextField: UIViewRepresentable {
    



    @Binding var text: String
    @Binding var wantToMakeFirstResponder: Bool
    @Binding var calculatedHeight: CGFloat
    //@Binding var isEmoji: Bool
    var placeHolderText: String
    
    


    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: MessagingTextField
        var didBecomeFirstResponder: Bool
        

        
        init(_ parent : MessagingTextField) {
            //print("coordinatorINIT")
            self.parent = parent
            //parent.edgesIgnoringSafeArea(.all)
            self.didBecomeFirstResponder = false
        


        }


        

        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.textColor = UIColor.black
            print("textViewDidBeginEditing")
            textView.subviews[2].isHidden = !textView.text.isEmpty
            parent.wantToMakeFirstResponder = true
            

            
            

        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            //print("textViewDidEndEditing")
            //print("In coordinator text is: ", self.parent.text)
            textView.subviews[2].isHidden = !textView.text.isEmpty
  

        }
        func textViewDidChange(_ textView: UITextView) {
            
            //print("textViewDidChange")
            self.parent.$text.wrappedValue = textView.text
            textView.subviews[2].isHidden = !textView.text.isEmpty
            parent.recalculateHeight(view: textView, result: parent.$calculatedHeight)

            
            
//
            //let size = CGSize(width: textView.frame.width, height: .infinity)
            //let estimatedSize = textView.sizeThatFits(size)
            
            
            //iphone11 pro max
            //width: 332.0
            //height: 37.666666666666664
            
            //iphone8
            //width0: 175
            //width: 293.0
            //height: 37.5
        }
        
        //any UIKit related UITextView methods for custom functionality need to go here
    
        
    }
    
    func makeCoordinator() -> Coordinator {
        //print("make Coordinator")
        return Coordinator(self)

    }
    
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        
        
//        print("\n\n")
//        print("update UIView")
//        if uiView.text.count > 1 && text.count == 0 {
//            print("ANIMATING ON DELETED MESSAGE")
//            withAnimation(.linear(duration: 1)) {
//                uiView.text = text
//                recalculateHeight(view: uiView, result: $calculatedHeight)
//            }
//
//        } else {
            uiView.text = text
            recalculateHeight(view: uiView, result: $calculatedHeight)
//        }
//        print("calculatedHeight: ", calculatedHeight)
    

        //context.coordinator.parent = self
//        print("UIVIEW HEIGHT:", uiView.frame.height)
//        print("UIVIEW WIDTH:", uiView.frame.width)
        
        
//
//        if wantToMakeFirstResponder && !context.coordinator.didBecomeFirstResponder {
//            uiView.becomeFirstResponder()
//            context.coordinator.didBecomeFirstResponder = true
//
//        }
    }
    


    

    func makeUIView(context: Context) -> UITextView {
        
        //print("MakeUIView")

        
        
        let textView = UITextView()
        
        textView.keyboardType = .asciiCapable// NOT ALLOWING EMOJIS

        
        
        
        //textView.frame = CGRect(x: 0, y: 0, width: 293, height: 40)
        
        
        textView.delegate = context.coordinator
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = UIColor.gray
        
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = false
        
        //print("KEYBOARD TYPE: ", textView.keyboardType)

        //textView.adjustsFontForContentSizeCategory = true
        //textView.layer.masksToBounds = true
        //textView.layer.masksToBounds = true
        //textView.layer.borderWidth = 0
        //textView.sizeToFit()
        

        let messTFPlaceholder = UILabel()
        messTFPlaceholder.text = placeHolderText
        messTFPlaceholder.font = .systemFont(ofSize: 18)
        messTFPlaceholder.sizeToFit()
        textView.addSubview(messTFPlaceholder)
        messTFPlaceholder.frame.origin = CGPoint(x: 10, y: 9)
        messTFPlaceholder.textColor = .lightGray
        //textView.layer.removeAllAnimations()
        
        
        textView.subviews[2].isHidden = !textView.text.isEmpty
        
        
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

//
//        textView.bottomAnchor.constraint(equalTo: textView.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        textView.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
//        textView.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true
//        textView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    

        return textView
    }
    
    
    func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
         let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
         if result.wrappedValue != newSize.height {
               DispatchQueue.main.async {
//                   withAnimation(.linear(duration: 0.3)) {
                       result.wrappedValue = newSize.height
//                   }
                     // call in next render cycle.
//                print("RECALCULATING SIZE, newSize: ", newSize)
        }
    }
        
    }
    
    
}
//extension Publishers {
//    // 1.
//    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
//        // 2.
//        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
//            .map { $0.keyboardHeight }
//        
//        
//        
//
//        //let willChange
//
//        
//        
//        
//        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
//            .map { _ in CGFloat(0) }
//        
//        // 3.
//        return MergeMany(willShow, willHide)
//            .eraseToAnyPublisher()
//    }
//}

// extension for keyboard to dismiss
//@objc private func _KeyboardHeightChanged(_ notification: Notification){
//    if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
//        UIView.animate(withDuration: 0.5, animations: {
//            self.SampleViewBottomConstaint.constant == 0 ? (self.SampleViewBottomConstaint.constant = frame.cgRectValue.height) : (self.SampleViewBottomConstaint.constant = 0)
//        })
//
//    }
//}
extension UIApplication {
    


    func endEditing() {
//        print("endEditing")
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func openKeyboard(){
//        print("openKeyboard")
        sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
    }
        
//    func _KeyboardHeightChanged(notification: Notification) {
//        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
//            print(frame)
//            }
//
//        }
//    }
        
    
//    func isKeyboardOpen() {
//        sendAction(#selector() to: UIResponder., from: nil, for: nil)
//    }
    

    
}


struct Test: View {
    @State var message = " fjkldas  ljfdklls dfdaf fdsa fdsa fdsa fdsa fdsa fdas fdsa fdsa fdsa fdsfdsaf dsa  jlkfd sa jfdklsa; jfkdl;a jfdk;la lfjdk;las jdklsa; fdkl;aj"
    @State var placeHolderText = "Send Message"
    @State var moveGrayContainerUp = false
    @State var textFieldHeight: CGFloat = 37.5
    @State var currentDate = Date()
    //@State var isEmoji: Bool = false
    var body: some View {
        ZStack {
            VStack(spacing: 0){
                
                //Color.orange.frame(height: 65)
                //Color.black.frame(height: 35)//new day
                //Color.blue.frame(height: 699)
//                Color.purple.frame(height: 27)
//                Color.purple.frame(height: 27)
//                Color.red.frame(height: 20 * 1 + 70)
//                Color.purple.frame(width: .infinity ,height: 427).frame(maxWidth: .infinity, alignment: .leading)
//                Color.gray.frame(height: 65)
//                Color.green.frame(height: 16 * 8 + 46)
//                Color.red.frame(height: 20 * 1 + 70)
//                Color.pink.frame(height: 568)
////                Color.green.frame(height: 17 * 8 + 45)
////                Color.pink.frame(height: 17 * 1 + 45 + 30)
////                Color.red.frame(height: 20 * 1 + 70)
////                Color.red.frame(height: 20 * 1 + 70)
//                Spacer()
//                //Color.gray.frame(height: 398)
//                Color.gray.frame(height: 118)
                Color.gray.frame(height: 100)
                //GRAY CONTAINER WITHOUT KEYBOARD
                Spacer()
                Color.red.frame(height: 360) //info
                Spacer()
                Color.green.frame(height: 96 + 16)//verify with one line
                
                Spacer()
                //KEYBOARD HEIGHT IPHONE 12 MINI
                //Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)).frame(height: 320)
                
                
                //KEYBOARD HEIGHT IPHONE 8
                //Color(#colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1)).frame(height: 256)
                

                
                

                


            }.edgesIgnoringSafeArea(.all)
//            VStack {
//                Spacer()
//                Color.init("keyboardGrey").frame(height: moveGrayContainerUp ? 240 + 75 + self.textFieldHeight: 75 + self.textFieldHeight, alignment: .bottom)
//            }
//            VStack {
//            Spacer()
//                VStack(spacing: 0) {
//                    MessagingTextField(text: $message, wantToMakeFirstResponder: $moveGrayContainerUp, calculatedHeight: $textFieldHeight, placeHolderText: placeHolderText)
//
//                }
//            .padding(EdgeInsets(top: 10, leading: 20, bottom: 65, trailing: 20))
//            .frame(maxWidth: .infinity, maxHeight: 75 + self.textFieldHeight)
//            //.frame(maxWidth: .infinity, maxHeight: 112.5)
//            //.padding(.bottom, 10)
//            .background(Color.init("keyboardGrey"))
//            .offset(y: moveGrayContainerUp ? -260 - textFieldHeight: 0)
//            }

        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct MessagingTextField_Previews: PreviewProvider {
    static var previews: some View {
//        MessagingTextField(text: .constant("This is my message"), wantToMakeFirstResponder: .constant(false), calculatedHeight: .constant(40), placeHolderText: "Send Message")
        //TextField("Test", text: .constant("te")).background(Color.init(UIColor.systemGray5))
        Test()
    }
}
