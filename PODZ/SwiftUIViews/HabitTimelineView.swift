//
//  HabitTimelineView.swift
//  PODZ
//
//  Created by Nick Miller on 1/25/22.
//  Copyright © 2022 Nick Miller. All rights reserved.
//

import SwiftUI
import UIKit



struct PickTimesView : View {


//    @State var reminderTime: Int = 900
//    @State var startHabitTime: Int = 1000
//    @State var habitTimeLength: Int = 200
//
//    @State var startHabitNeeded = 0
//
//    @State var endHabitNeeded = 23
//
    @Binding var chosenHabitType: Bool
    @Binding var chosenTimes : Bool
//
//    @State var currentReminderDate: Date = Date()
    
    @ObservedObject var timelineHelper = TimelineHelper(viewWidth: UIScreen.main.bounds.width)
    
    @State var step: Int = 0
    
    let titles : [String] = ["Choose Habit Start Time", "Choose Habit Time Length", "Choose Reminder Time"]
    
    
    func currentDateToTimeAsHHMM(currentDate: Date) -> Int {
        return Calendar.current.component(.hour, from: currentDate) * 100 + Calendar.current.component(.minute, from: currentDate)
    }
    
//    @State var habitLength: Double = 3600
    
    
    var body: some View {
//
        VStack(alignment: .center) {
//
            Text(titles.indices.contains(step) ? titles[step] : "TITLE")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom)

            
            if step == 2 {
                
                DatePicker("Select Reminder Time", selection: $timelineHelper.reminderTime, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(width: .infinity, height: 80, alignment: .center)
                    .clipped()
                    .foregroundColor(.purple)
                    .accentColor(.purple)
                    .labelsHidden()
                    .frame(width: .infinity, height: 80, alignment: .center)
            } else if step == 0 {
                
                    DatePicker("Select Habit Time", selection: $timelineHelper.habitTime, displayedComponents: .hourAndMinute).datePickerStyle(WheelDatePickerStyle())
                        .datePickerStyle(WheelDatePickerStyle())
                        .frame(width: .infinity, height: 80, alignment: .center)
                        .clipped()
                        .foregroundColor(.purple)
                        .accentColor(.purple)
                        .labelsHidden()
                        .frame(width: .infinity, height: 80, alignment: .center)
            } else if step == 1 {
                
                DurationPicker(duration: $timelineHelper.habitLength)
            }
//            VStack {
//                Text(String(currentDateToTimeAsHHMM(currentDate: timelineHelper.reminderTime)))
//                Text(String(currentDateToTimeAsHHMM(currentDate: timelineHelper.habitTime)))
//                Text(String(timelineHelper.habitLength))
//                 }

            Spacer()
            
//
//            NewHabitTimeLineView(reminderTime: currentDateToTimeAsHHMM(currentDate: currentReminderDate), startHabitTime: startHabitTime, habitTimeLength: habitTimeLength, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded,
            
            GeometryReader { geo in
                ThirdTimlineView(viewHeight: geo.size.height, viewWidth: geo.size.width, timelineHelper: timelineHelper, step: $step)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }

            Spacer()

            HStack {
                Button(action: {


                    if step == 1 {
                        chosenHabitType = false
                    } else {
                        step = step - 1
                    }
                    


                }, label: {
                    HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                    Text("Back")
                        .foregroundColor(.black)
                        .bold()
                        .font(.title2)
                        .padding()


                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                    .padding()

                    }
                )

            Button(action: {
                if step == 3 {
                    chosenTimes = true
                }
                else {
                    step = step + 1
                }
                    
                
            }, label: {
                HStack {
                Text("Next")
                    .foregroundColor(.white)
                    .bold()
                    .font(.title2)
                    .padding()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .background(Color.purple)
                .cornerRadius(10)
                .padding()

                })
            }

        }
    }
}

struct DurationPicker: UIViewRepresentable {
    @Binding var duration: Double

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.updateDuration), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ datePicker: UIDatePicker, context: Context) {
        datePicker.countDownDuration = duration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: DurationPicker

        init(_ parent: DurationPicker) {
            self.parent = parent
        }

        @objc func updateDuration(datePicker: UIDatePicker) {
            parent.duration = datePicker.countDownDuration
        }
    }
}



class TimelineHelper: ObservableObject {
    @Published var dotType : [String]
    
    @Published var reminderTime: Date
//    {
//        didSet{
//            timesChanged()
//        }
//    }
//
    @Published var habitTime: Date
//    {
//        didSet{
//            timesChanged()
//        }
//    }
    @Published var habitLength: Double
//    {
//        didSet{
//            timesChanged()
//        }
//    }
    
    @Published var startHabitNeeded = 0
    @Published var endHabitNeeded = 23
    @Published var isEndHabitNextDay : Bool = false
    let viewWidth: CGFloat
    let numberOfDots: Int
    
    
    init(viewWidth: CGFloat) {
        self.viewWidth = viewWidth
        self.numberOfDots = 15
        
//        self.dotType = []
        var middle = Array(repeating: "None", count: numberOfDots - 1)
        var startArray = ["Start"]
        var endArray = ["End"]
        self.dotType = startArray + middle + endArray
//        self.dotType = ["startHabitNeeded", "Space", "Start", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "None", "End", "Space", "endHabitNeeded"]

        self.habitLength = 3600
        self.reminderTime = Date()
        self.habitTime = Date()
        self.resetTimeline()
        
        
    }
    
    func timesChanged() {
        
        updateBounds() {
            
            
            resetTimeline()
            dotType[convertDateToIndex(date: habitTime)] += " HabitStart"
            
            let numberOfDotsInDuration = amountOfDotsInDuration(duration: habitLength)
            var habitIndex = convertDateToIndex(date: habitTime)
            var currentIndex = habitIndex
            for _ in 0..<numberOfDotsInDuration {
                
                habitIndex = habitIndex + 1
                
                if habitIndex < numberOfDots {
                    currentIndex = habitIndex
                    dotType[habitIndex] += " Habit"
                } else {
                    habitIndex = 0
                    currentIndex = 0
                    dotType[habitIndex] += " Habit"
                }
            }
            if currentIndex < numberOfDots {
                dotType[currentIndex + 1] = " HabitEnd"
            } else if currentIndex == numberOfDots {
                dotType[currentIndex] += " HabitEnd"
            }
    //
            let calendar = Calendar.current
            let endHabit = calendar.date(byAdding: .second, value: Int(habitLength), to: habitTime)!
            dotType[convertDateToIndex(date: endHabit)] += " Group"
            
            if convertDateToIndex(date: endHabit) == convertDateToIndex(date: reminderTime) && convertDateToIndex(date: endHabit) != 0 {
                
                dotType[convertDateToIndex(date: endHabit) - 1] += " Reminder"

            } else {
                dotType[convertDateToIndex(date: endHabit)] += "Reminder"

            }
            


        }

        

        
    }
    
    func printTimelineHelper() {
        print("")
        
        print("numberOfDots: ", self.numberOfDots, "  SegLength: ", segLength())

        print("dotType array: ", dotType)
        
        print("reminderTime: ", reminderTime)
        print("reminderTime Index: ", convertDateToIndex(date: reminderTime))
        
        print("habitStartTime: ", habitTime)
        print("habitTimeStart Index: ", convertDateToIndex(date: habitTime))
        
        print("habitLength: ", habitLength)
        print("amountOfDotsInDuration: ", amountOfDotsInDuration(duration: habitLength))
        
        
        let calendar = Calendar.current
        let endHabit = calendar.date(byAdding: .second, value: Int(habitLength), to: habitTime)!
        print("habitTimeEnd: ", endHabit)
        print("habitTimeEnd Index: ", convertDateToIndex(date: endHabit))
        
        
        
        print("startHabitNeeded: ", startHabitNeeded)
        print("endHabitNeeded: ", endHabitNeeded)
        print("")

    }
    
    func amountOfDotsInDuration(duration: Double) -> Int {
        let minutesPerDot: Double = Double(endHabitNeeded - startHabitNeeded) * 60 / Double(self.numberOfDots)
        let dots: Double = (duration/60)/minutesPerDot
        return Int(dots)
    }
    
    func convertDateToIndex(date: Date) -> Int {
        
        print("")
        
        let timeAsHHMM: Double =  Double(Calendar.current.component(.hour, from: date) * 100 + Calendar.current.component(.minute, from: date))
        
        print("convertDateToIndex for timeAsHHMM: ", timeAsHHMM)
        
        let minusStartingHour = timeAsHHMM - Double(startHabitNeeded * 100)
        
        print("minusStartingHour: ", minusStartingHour)

        
        let fullTimeline = Double(self.endHabitNeeded - self.startHabitNeeded)
        
//        print("fullTimeline: ", fullTimeline)
        print("startHabit: ", startHabitNeeded, "endHabit: ", endHabitNeeded)
        
        let fullTimelineConverted: Double = fullTimeline * 100
        
//        print("fullTimelineConverted: ", fullTimelineConverted)
        
        let percentageIndexOnTimeline: Double = minusStartingHour * fullTimelineConverted / 2400
        
        print("percentageIndexOnTimeline: ", percentageIndexOnTimeline)
        
        let convertedToIndex: Int = Int(percentageIndexOnTimeline * Double(self.numberOfDots)) / 100
        
        print("convertedToIndex: ", convertedToIndex)
        print("")

        return convertedToIndex
    }
    func updateBounds(completion: (() -> ()) ) {
        
        let calendar = Calendar.current
        let endHabit = calendar.date(byAdding: .second, value: Int(habitLength), to: habitTime)!
        let endHabitHour = Int(Calendar.current.component(.hour, from: endHabit))
        let reminderTimeHour = Int(Calendar.current.component(.hour, from: reminderTime))
        let habitTimeHour = Int(Calendar.current.component(.hour, from: habitTime))
        
        if endHabitHour < habitTimeHour {
            isEndHabitNextDay = true
        }
        
        
        startHabitNeeded = min(reminderTimeHour, habitTimeHour, endHabitHour) - 2
        endHabitNeeded = max(reminderTimeHour, habitTimeHour, endHabitHour) + 2
        
        if startHabitNeeded < 0 {
            startHabitNeeded = 0
        }
        if endHabitNeeded > 23 {
            endHabitNeeded = 23
        }
        
        
        completion()
        
        

    }
    func resetTimeline() {
        var middle = Array(repeating: "", count: numberOfDots - 2)
        var startArray = ["Start"]
        var endArray = ["End"]
        self.dotType = startArray + middle + endArray
//        self.dotType = []
//        for i in 0..<100 {
//            if i == 0 {
//                self.dotType.append("startHabitNeeded")
//
//            } else if i == 99 {
//                self.dotType.append("endHabitNeeded")
//            }
//            else if i == 98 {
//                self.dotType.append("Space")
//            }
//            else if i == 1 {
//                self.dotType.append("Space")
//            }
//            else if i == 2 {
//                self.dotType.append("End")
//
//            }
//            else if i == 97 {
//                self.dotType.append("Start")
//            }
//
//            else {
//                self.dotType.append("None")
//            }
//        }
    }
    func segLength() -> CGFloat {
        
        let giveAGap: CGFloat = self.viewWidth - 30
        
        
        
        return giveAGap / CGFloat(self.numberOfDots)
    }
    func convertHour(hour: Int) -> String {
        if hour == 0 {
            return  "12am"
        } else if hour < 12 {
            return String(hour) + "am"
        } else if hour == 12 {
            return "12pm"
        }
        else {
            return String(hour - 12) + "pm"
        }
    }

}


struct ThirdTimlineView : View {
    
    
    let viewHeight: CGFloat
    let viewWidth: CGFloat
    
    @ObservedObject var timelineHelper: TimelineHelper
    
    
    
    
    @State var reminderTime: Int = 1200
    @State var startHabitTime: Int = 1200
    @State var habitTimeLength: Int = 80
    
    @State var startHabitNeeded = 0
    
    @State var endHabitNeeded = 23
    @Binding var step: Int
    
//    func twoThings(dot: String) -> [String] {
//       let arrayOfSubstrings =  dot.components(separatedBy: " ")
//        var arrayOfStrings: [String] = []
//        arrayOfSubstrings.map { subS in
//            arrayOfStrings.append(String(subS))
//        }
//        return arrayOfStrings
//
//
//    }
    
    var body : some View {
        
        HStack(spacing: 0) {
            ForEach(timelineHelper.dotType, id: \.self) {
                dot in

                        
                    ForEach(twoThings(dot: dot), id: \.self) { word in
                        VStack {
                            if word.count == 1 && word[0] == "" {
                                Color.black.frame(maxWidth: timelineHelper.segLength(), maxHeight: 3, alignment: .center)
                            } else {
                            
                            if word == "Start" {
                                
                                VStack {
                                    Circle()
                                        .fill(Color.white.opacity(1))
                                        .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
                                    
                                    HStack(spacing: 0) {
                                        Color.black.frame(width: 3, height: 20, alignment: .center)
                                        Color.black.frame(width: timelineHelper.segLength() - 3, height: 3, alignment: .center)
                                    }
                                    
                                    Text(timelineHelper.convertHour(hour: timelineHelper.startHabitNeeded))
                                        .lineLimit(1)
                                        .fixedSize()
                                        .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
                                    
                                }
                            } else if word == "End"  {
                                
                                VStack {
                                    Circle()
                                        .fill(Color.white.opacity(1))
                                        .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
                                    
                                    HStack(spacing: 0) {
                                        Color.black.frame(width: timelineHelper.segLength() - 3, height: 3, alignment: .center)
                                        Color.black.frame(width: 3, height: 20, alignment: .center)

                                    }
                                    
                                    Text(timelineHelper.convertHour(hour: timelineHelper.endHabitNeeded))
                                        .lineLimit(1)
                                        .fixedSize()
                                        .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
                                    
                                }
                            }
//                            else if word == "Reminder" {
//                                Circle()
//                                    .fill(Color.green.opacity(1))
//                                    .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
//                            }
//                            else if word == "Habit" {
//                                Color.gray.frame(maxHeight: timelineHelper.segLength(), alignment: .center)
//                            }
////                            else if word == "Space" {
////                                Circle()
////                                    .fill(Color.white.opacity(1))
////                                    .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
////                            }
//                            else if word == "HabitStart" {
//
//                                Color.gray.frame(maxHeight: timelineHelper.segLength(), alignment: .center)
//                                    .cornerRadius(100, corners: [.topLeft, .bottomLeft])
//                            }
//                            else if word == "HabitEnd" {
//                                Color.gray.frame(maxHeight: timelineHelper.segLength(), alignment: .center)
//                                    .cornerRadius(100, corners: [.topRight, .bottomRight])
//                            }
//                            else if word == "Group" {
//                                Circle()
//                                    .fill(Color.purple.opacity(1))
//                                    .frame(width: timelineHelper.segLength(), height: timelineHelper.segLength())
//                            }
                        }
        
                    }.frame(width: timelineHelper.segLength(), height: timelineHelper.segLength(), alignment: .center)
                }
            }
        }
        .onChange(of: timelineHelper.reminderTime) { changed in
            print("BEFORE CHANGE onChange(of: timelineHelper.reminderTime)")
            timelineHelper.printTimelineHelper()

            timelineHelper.timesChanged()
            
            print("AFTER CHANGE")
            timelineHelper.printTimelineHelper()
        }
        .onChange(of: timelineHelper.habitTime) { changed in
            print("onChange(of: timelineHelper.habitTime)")
            timelineHelper.printTimelineHelper()

            timelineHelper.timesChanged()
            print("AFTER CHANGE")
            timelineHelper.printTimelineHelper()

        }
        .onChange(of: timelineHelper.habitLength) { changed in
            print("onChange(of: timelineHelper.habitLength)")
            timelineHelper.printTimelineHelper()
            timelineHelper.timesChanged()
            print("AFTER CHANGE")
            timelineHelper.printTimelineHelper()

        }
        
        .frame(width: viewWidth, height: viewHeight, alignment: .center)

            
        
        
    }
}

struct NewHabitTimeLineView : View {
    
    @State var reminderTime: Int = 1200
    @State var startHabitTime: Int = 1200
    @State var habitTimeLength: Int = 80
    
    @State var startHabitNeeded = 0
    
    @State var endHabitNeeded = 23
    @Binding var step: Int
//
    func convertHour(hour: Int) -> String {
        if hour == 0 {
            return  "12am"
        } else if hour < 12 {
            return String(hour) + "am"
        } else if hour == 12 {
            return "12pm"
        }
        else {
            return String(hour - 12) + "pm"
        }
    }
    

    func moveTowardCenter(time: Int, screenWidth : CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {

        //time is written as four digit int. EX: 8:30am is written as 830. 1:30pm is written as 1330

        let timelineLength: CGFloat = screenWidth - 20

        let totalTimeOnTimeline : CGFloat = 100 * (CGFloat(endHabitNeeded) - CGFloat(startHabitNeeded))
        let startTimeOnTimeline: CGFloat = CGFloat(time) - CGFloat(startHabitNeeded) * 100


        let value : CGFloat = startTimeOnTimeline * timelineLength / totalTimeOnTimeline
        let middleTime : CGFloat = totalTimeOnTimeline * 0.5
        let gap : CGFloat = middleTime - value


        return gap * 0.1

    }

    func reminderTimeToXValue(time: Int, screenWidth : CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {

        //time is written as four digit int. EX: 8:30am is written as 830. 1:30pm is written as 1330

        let timelineLength: CGFloat = screenWidth - 20

        let totalTimeOnTimeline : CGFloat = 100 * CGFloat(endHabitNeeded - startHabitNeeded)
        let startTimeOnTimeline = time - startHabitNeeded * 100


        let value : CGFloat = CGFloat(startTimeOnTimeline) * CGFloat(timelineLength) / (totalTimeOnTimeline)
//        if screenWidth - value < 80 {
//            return value - (screenWidth - value) * 0.5
//        } else if value < 100 {
//
//            return value + value * 0.5
//
//            } else {
//                return value
//
//            }
        return value
    }

    func findCapsuleLength(time: Int, screenWidth : CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {

        //time is written as four digit int. EX: 8:30am is written as 830. 1:30pm is written as 1330

        let timelineLength: CGFloat = screenWidth - 20

        let totalTimeOnTimeline : CGFloat = 100 * (CGFloat(endHabitNeeded) - CGFloat(startHabitNeeded))
        let startTimeOnTimeline = time


        return CGFloat(startTimeOnTimeline) * CGFloat(timelineLength) / totalTimeOnTimeline

    }

    
    var body: some View {
        GeometryReader { geo in
        ZStack {
            
            VStack {
                Text("reminder time move toward Center").font(.system(size: 12))
                HStack {
                    Text(String(Int(moveTowardCenter(time: reminderTime, screenWidth: geo.size.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded)))).font(.system(size: 12))
                    Text("reminderTime " + String(reminderTime)).font(.system(size: 12))
                }
                Text("startHabit time move toward Center").font(.system(size: 12))

                HStack {
                    Text(String(Int(moveTowardCenter(time: startHabitTime, screenWidth: geo.size.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded)))).font(.system(size: 12))
                    Text("startHabitTime " + String(startHabitTime)).font(.system(size: 12))
                }

                Text("endHabit time move toward Center").font(.system(size: 12))

                HStack {
                    Text(String(Int(moveTowardCenter(time: startHabitTime + habitTimeLength, screenWidth: geo.size.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded)))).font(.system(size: 12))
                    Text("startHabitTime + habitTimeLength " + String(startHabitTime + habitTimeLength)).font(.system(size: 12))
                }


                Text("endHabit time offset").font(.system(size: 12))

                Text(String(Int(reminderTimeToXValue(time: startHabitTime + habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded)))).font(.system(size: 12))
            }
            .offset(x: 0, y: -100)
            
        HStack(spacing: 0)  {
            
            VStack {
                Color.black.frame(maxWidth: 6, maxHeight: 50, alignment: .center)
                Text(convertHour(hour: startHabitNeeded))
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: 10, y: 0)
            }.offset(x: 17, y: 10)
        
            
            Color.black.frame(maxWidth: .infinity, maxHeight: 3, alignment: .center)

            VStack {
                Color.black.frame(maxWidth: 6, maxHeight: 50, alignment: .center)
                Text(convertHour(hour: endHabitNeeded))
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: -10, y: 0)

            }
            .offset(x: -20, y: 10)
            
        }
        .position(x: geo.size.width * 1/2, y: geo.size.height * 1/10)
//        .offset(x: 0, y: -40)
            


        
            ZStack {

                VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.7))
                                .frame(width: 20, height: 20)

                        }

                        Color.green.frame(maxWidth: 3, maxHeight: 40, alignment: .center)

                        VStack(alignment: .leading) {
                            Text("Reminder Notification")
                                .lineLimit(1)
                                .fixedSize()
                                    .foregroundColor(.white)
                                    .font(.system(size: 13))
                            Text("at " + timeAsHHMMIntToStringInChat(timeAsHHMM: reminderTime) )
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .fixedSize()

                        }
                        .padding(5)
                        .background(Color.green)
                        .cornerRadius(5)

                    }
//                    .offset(x: reminderTimeToXValue(time: reminderTime, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) + geo.size.width * 0.2, y: 43)
                    .opacity((step == 1 || step == 4) ? 1 : 0.5)
                    .position(x: reminderTimeToXValue(time: reminderTime, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded), y: geo.size.height * 1/6 - 35)
                //232

                VStack(spacing: 2) {

                        HStack() {
                            Text("Start habit at " + timeAsHHMMIntToStringInChat(timeAsHHMM: startHabitTime))
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .fixedSize()
                            Text("|")
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .fixedSize()
                            Text("habit takes " + String(habitTimeLength) + " minutes " )
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                                .lineLimit(1)
                                .fixedSize()

                        }
                        .padding(5)
                        .background(Color.gray)
                        .cornerRadius(5)
                        .frame(width: geo.size.width, alignment: .center)
                        .offset(x: moveTowardCenter(time: startHabitTime, screenWidth: UIScreen.main.bounds.width, startHabitNeeded:  startHabitNeeded, endHabitNeeded: endHabitNeeded), y: 0)

                    Color.gray.frame(maxWidth: 3, maxHeight: 40, alignment: .center)

                        HStack {
                            Capsule()
                                .fill(Color.gray)
                                .frame(width: findCapsuleLength(time: habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded),
                                       height: 20,
                                       alignment: .top)

                        }

                    }
//                    .offset(x: 0, y: -67)
                    .position(x: reminderTimeToXValue(time: startHabitTime + habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) - findCapsuleLength(time: habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded), y: geo.size.height * 1/6 - 113)
                    .opacity((step == 2 || step == 4) ? 1 : 0.6)
                    .zIndex(-2)
                //155
//
//
//
                VStack(spacing: 2) {

                        Circle()
                            .fill(Color.purple.opacity(1))
                            .frame(width: 20, height: 20)

                            Color.purple.frame(width: 3, height: 110, alignment: .center)

                        GroupNotifyTimeLineView(startHabitTime: $startHabitTime, habitTimeLength: $habitTimeLength)
                        .offset(x: moveTowardCenter(time: startHabitTime + habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded), y: 0)
                }
                .zIndex(-1)
                .opacity((step == 3 || step == 4) ? 1 : 0.5)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .position(x: reminderTimeToXValue(time: startHabitTime + habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded), y: geo.size.height * 1/6)
                //268

//                .offset(x: reminderTimeToXValue(time: startHabitTime + habitTimeLength, screenWidth: UIScreen.main.bounds.width, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) - geo.size.width * 1.5, y: 77)
//
//
            }
            .frame(width: geo.size.width)
            .offset(x: 0, y: 40)
            }
            .offset(x: 0, y: 90)
            .onChange(of: reminderTime) { t in
                startHabitNeeded = min(reminderTime/100, startHabitTime/100)
                endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
                if startHabitNeeded > 1 {
                    startHabitNeeded = startHabitNeeded - 2
                }
                if endHabitNeeded < 22 {
                    endHabitNeeded = endHabitNeeded + 2
                }
            }
            .onChange(of: habitTimeLength) { t in
                startHabitNeeded = min(reminderTime/100, startHabitTime/100)
                endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
                if startHabitNeeded > 1 {
                    startHabitNeeded = startHabitNeeded - 2
                }
                if endHabitNeeded < 22 {
                    endHabitNeeded = endHabitNeeded + 2
                }
            }
            .onChange(of: startHabitTime) { t in
                startHabitNeeded = min(reminderTime/100, startHabitTime/100)
                endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
                if startHabitNeeded > 1 {
                    startHabitNeeded = startHabitNeeded - 2
                }
                if endHabitNeeded < 22 {
                    endHabitNeeded = endHabitNeeded + 2
                }
            }
            .onAppear {

                startHabitNeeded = Int(min(CGFloat(reminderTime)/100, CGFloat(startHabitTime)/100))
                endHabitNeeded = Int(max(CGFloat(reminderTime)/100, CGFloat(startHabitTime)/100))
                if startHabitNeeded > 1 {
                    startHabitNeeded = startHabitNeeded - 2
                }
                if endHabitNeeded < 22 {
                    endHabitNeeded = endHabitNeeded + 2
                }
    //            endHabitNeeded = 13
    //            startHabitNeeded = 7
    //                        endHabitNeeded = 18
    //                        startHabitNeeded = 6

                //            endHabitNeeded = 23
                //            startHabitNeeded = 0



            }
        }
    }
}



func timeToYValue(time: Int, screenHeight: CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {

    //time is written as four digit int. EX: 8:30am is written as 830. 1:30pm is written as 1330
    
    let totalTimeOnTimeline : CGFloat = 100 * CGFloat(endHabitNeeded - startHabitNeeded)
    let startTimeOnTimeline = time - startHabitNeeded * 100
    
    
    let boost: CGFloat = 108
    let up: CGFloat = 30
    //            endHabitNeeded = 13
    //            startHabitNeeded = 7
    //40
    
    return  CGFloat(startTimeOnTimeline) * CGFloat(screenHeight) / (totalTimeOnTimeline + boost) - up //- screenHeight * 0.5

}

func timeToCapsuleHeight(time: Int, screenHeight: CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {
    let totalTimeOnTimeline : CGFloat = 100 * CGFloat(endHabitNeeded - startHabitNeeded)
    
    let boost: CGFloat = 0
    let up: CGFloat = 0

    
    let capsuleHeight : CGFloat = CGFloat(time) * screenHeight / (totalTimeOnTimeline + boost) - up

    return capsuleHeight
}


struct HabitTimelineView: View {
    
    func convertHour(hour: Int) -> String {
        if hour == 0 {
            return  "12am"
        } else if hour < 12 {
            return String(hour) + "am"
        } else if hour == 12 {
            return "12pm"
        }
        else {
            return String(hour - 12) + "pm"
        }
    }
//

    func calculateTimeLineYOffset(screenSize: CGFloat, startHabitNeeded: Int, endHabitNeeded: Int) -> CGFloat {
        let hoursOnTimeline = endHabitNeeded - startHabitNeeded
        
        //if screenSize is 845, hoursOnTimeline is 24, return -15
        //if screenSize is 845, hoursOnTimeline is 12, return -47
        
        //if screen size is 696, hours on timeline is 24, return -30
        //if screen size is 696, hours on timeline is 12, return - 42
        
        
        //if screensize is  647, hours on timeline is 24, return -30
        //if screensize is 647, hours on timeline is 12, return -30

         
        
        // less
        return -450 / CGFloat(hoursOnTimeline)
        
    }
    
//
    @State var reminderTime: Int = 900
    @State var startHabitTime: Int = 1630
    @State var habitTimeLength: Int = 100
    
    @State var startHabitNeeded = 0
    @State var endHabitNeeded = 23
    
    
    var body: some View {
        
        ZStack {
            GeometryReader { geo in
                
                        Text(String(Int(calculateTimeLineYOffset(screenSize: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded)))).offset(x: -50, y: 0)
                            ForEach(Range(startHabitNeeded...endHabitNeeded), id: \.self) { hour in

                                Circle()
                                    .frame(width: 10, height: 10, alignment: .center)
                                    .offset(x: geo.size.width * 0.5 - 5,
                                            y: CGFloat(hour - startHabitNeeded) * CGFloat(geo.size.height) / CGFloat(1 + endHabitNeeded - startHabitNeeded))
                            }
                            .frame(maxWidth: 10, maxHeight: .infinity, alignment: .top)

                            ZStack {
                                Color.black.frame(maxWidth: 3, maxHeight: .infinity, alignment: .center)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                        ForEach(Range(startHabitNeeded...endHabitNeeded), id: \.self) { hour in

                                Text(convertHour(hour: hour))
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .fixedSize()
                                .position(x: geo.size.width * 0.5 - 40, y: CGFloat(hour - startHabitNeeded) * CGFloat(geo.size.height) / CGFloat(1 + endHabitNeeded - startHabitNeeded) - 4)

                        }
                        .frame(maxWidth: 30, maxHeight: .infinity , alignment: .top)
//                        .offset(x: geo.size.width * 0.5, y: -4)

                
                PointsOnTimelineView(startHabitNeeded: $startHabitNeeded, habitTimeLength: $habitTimeLength, endHabitNeeded: $endHabitNeeded, startHabitTime: $startHabitTime, reminderTime: $reminderTime, geoScreenHeight: geo.size.height, geoScreenWidth: geo.size.width)

                
                
                VStack(alignment: .leading) {
                    Text("Reminder Notification")
                            .foregroundColor(.white)
                            .font(.system(size: 13))
                    Text("at " + timeAsHHMMIntToStringInChat(timeAsHHMM: reminderTime))
                        .foregroundColor(.white)
                        .font(.system(size: 12))

                }
                .padding(5)
                .background(Color.green)
                .cornerRadius(5)
                .offset(x: geo.size.width * 1/2,
                    y: timeToYValue(time: reminderTime, screenHeight: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded))
                .offset(x: 20, y: calculateTimeLineYOffset(screenSize: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) + 80)

                
                
                HabitTimeRangeCapsuleView(startHabitNeeded: $startHabitNeeded, habitTimeLength: $habitTimeLength, endHabitNeeded: $endHabitNeeded, startHabitTime: $startHabitTime, geoScreenHeight: geo.size.height)
                    .offset(x: geo.size.width * 1/12,
                            y: timeToYValue(time: startHabitTime, screenHeight: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded))
                    .offset(x: 20, y: calculateTimeLineYOffset(screenSize: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) + 80)
                
                GroupNotifyTimeLineView(startHabitTime: $startHabitTime, habitTimeLength: $habitTimeLength)
                .offset(x: geo.size.width * 1/2,
                        y: timeToYValue(time: startHabitTime + habitTimeLength, screenHeight: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded))
                .offset(x: 20, y: calculateTimeLineYOffset(screenSize: geo.size.height, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) + 80)
                        

            }
        }
        .onChange(of: reminderTime) { t in
            startHabitNeeded = min(reminderTime/100, startHabitTime/100)
            endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
            if startHabitNeeded > 1 {
                startHabitNeeded = startHabitNeeded - 2
            }
            if endHabitNeeded < 22 {
                endHabitNeeded = endHabitNeeded + 2
            }
        }
        .onChange(of: habitTimeLength) { t in
            startHabitNeeded = min(reminderTime/100, startHabitTime/100)
            endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
            if startHabitNeeded > 1 {
                startHabitNeeded = startHabitNeeded - 2
            }
            if endHabitNeeded < 22 {
                endHabitNeeded = endHabitNeeded + 2
            }
        }
        .onChange(of: startHabitTime) { t in
            startHabitNeeded = min(reminderTime/100, startHabitTime/100)
            endHabitNeeded = max(reminderTime/100, (startHabitTime + habitTimeLength)/100)
            if startHabitNeeded > 1 {
                startHabitNeeded = startHabitNeeded - 2
            }
            if endHabitNeeded < 22 {
                endHabitNeeded = endHabitNeeded + 2
            }
        }
        .onAppear {

            startHabitNeeded = Int(min(CGFloat(reminderTime)/100, CGFloat(startHabitTime)/100))
            endHabitNeeded = Int(max(CGFloat(reminderTime)/100, CGFloat(startHabitTime)/100))
            if startHabitNeeded > 1 {
                startHabitNeeded = startHabitNeeded - 2
            }
            if endHabitNeeded < 22 {
                endHabitNeeded = endHabitNeeded + 2
            }
//            endHabitNeeded = 13
//            startHabitNeeded = 7
//                        endHabitNeeded = 18
//                        startHabitNeeded = 6
            
            //            endHabitNeeded = 23
            //            startHabitNeeded = 0
            
            

        }
    }
}


struct GroupNotifyTimeLineView: View {
    
    
    @Binding var startHabitTime: Int
    @Binding var habitTimeLength: Int
    
    
    
    var body: some View {

            VStack(alignment: .leading) {
                Text("If you haven't logged your habit")
                        .foregroundColor(.white)
                        .font(.system(size: 13))
                        .lineLimit(1)
                        .fixedSize()
                Text("group will be notified at " + timeAsHHMMIntToStringInChat(timeAsHHMM: startHabitTime + habitTimeLength))
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(5)
            .background(Color.purple)
            .cornerRadius(5)
        
    }
}

struct HabitTimeRangeCapsuleView: View {
    
    
    @Binding var startHabitNeeded: Int
    @Binding var habitTimeLength: Int
    @Binding var endHabitNeeded: Int
    @Binding var startHabitTime: Int
    var geoScreenHeight: CGFloat
    
    var body: some View {
        
        
  
        

            
            VStack(alignment: .leading) {
                Text("Start habit at")
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                Text("at " + timeAsHHMMIntToStringInChat(timeAsHHMM: startHabitTime))
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                
            }
            .padding(5)
            .background(Color.gray)
            .cornerRadius(5)
            
        

    }
}










struct DiagonalLine : View {
    var leftPoint: CGPoint
    var rightPoint: CGPoint
    
    var body: some View {
        Path { path in

            path.move(to: leftPoint)
            path.addLine(to: rightPoint)
            
            

        }.stroke(Color.green, lineWidth: 3)
    }
}



struct HabitTimelineView_Previews: PreviewProvider {
    static var previews: some View {
        
//        PickTimesView(chosenHabitType: .constant(true), chosenTimes: .constant(false), step: 1)
//            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Mini"))
//            .previewDisplayName("iPhone 12 Mini")
        
        PickTimesView(chosenHabitType: .constant(true), chosenTimes: .constant(false), step: 1)
            .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
            .previewDisplayName("iPhone 12 Pro Max")

//        PickTimesView(chosenHabitType: .constant(true), chosenTimes: .constant(false), step: 2)
//            .previewDevice(PreviewDevice(rawValue: "iPhone 8"))
//            .previewDisplayName("iPhone 8")
        
    }
}

struct PointsOnTimelineView: View {
    
    @Binding var startHabitNeeded: Int
    @Binding var habitTimeLength: Int
    @Binding var endHabitNeeded: Int
    @Binding var startHabitTime: Int
    @Binding var reminderTime: Int
    var geoScreenHeight: CGFloat
    var geoScreenWidth: CGFloat
    
    var body: some View {
        ZStack {
            
            Circle()
                .fill(Color.green.opacity(0.7))
                .frame(width: 20, height: 20)
                .offset(x: geoScreenWidth * 0.5 - 10,
                        y: timeToYValue(time: reminderTime, screenHeight: geoScreenHeight, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded))
            
            Circle()
                .fill(Color.purple.opacity(0.7))
                .frame(width: 20, height: 20, alignment: .top)
                .offset(x: geoScreenWidth * 0.5 - 10,
                        y: timeToYValue(time: startHabitTime + habitTimeLength, screenHeight: geoScreenHeight, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded))

            
            
            Capsule()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 20,
                       height: timeToCapsuleHeight(time: habitTimeLength, screenHeight: geoScreenHeight, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded),
                       alignment: .top)
                .offset(x: geoScreenWidth * 0.5 - 10,
                        y: timeToYValue(time: startHabitTime, screenHeight: geoScreenHeight, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded) + 35)
            
            if startHabitTime + habitTimeLength > 2400 {
                
                Capsule()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 20,
                           height: timeToCapsuleHeight(time: startHabitTime + habitTimeLength - 2400 , screenHeight: geoScreenHeight, startHabitNeeded: startHabitNeeded, endHabitNeeded: endHabitNeeded),
                           alignment: .top)
                    .offset(x: geoScreenWidth * 0.5 - 10,
                            y: 0)
            }
        }
    }
}
