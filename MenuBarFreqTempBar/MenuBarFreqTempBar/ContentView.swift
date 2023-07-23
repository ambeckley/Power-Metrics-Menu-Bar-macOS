//
//  ContentView.swift
//  MenuBarFreqTempBar
//
//  Created by Aaron Beckley on 7/22/23.
//

import SwiftUI
import LocalAuthentication
import Darwin
import Foundation

//import Commands


class Helper {
    static func shell(launchPath path: String, arguments args: [String]) -> String {
        let task = Process()
        task.launchPath = path
        task.arguments = args

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        task.waitUntilExit()

        return(output!)
    }
}


struct ContentView: View {

    
    @State var isUpdated : Bool = false
    @State var verified : Bool = false
    @State var cpuTemp : String = ""
    @State var gpuTemp : String = ""
    @State var freq : String = ""
    @State var currentTime : String = ""
    var body: some View {
        VStack{
            if verified {
                //maybe add things to tell what previous values were
                //Text("Stats").padding()
                Text("TimeStamp: \(currentTime)").padding()
                Text("CPU Frequency: \(freq) Mhz").padding()
                Text("CPU: \(cpuTemp) C").padding()
                Text("GPU: \(gpuTemp) C").padding()
                Button("Update", action: {
                   
                    //updateStatusBarTitle(title: isUpdated ? "Test" : "TestIt")
                    //isUpdated.toggle()
                    let output = Helper.shell(launchPath: "/usr/bin/osascript", arguments: ["-e", "do shell script \"/usr/bin/powermetrics -n 1\" with administrator privileges"])
                    //print("*** temps ***:\n\(res)")
                    var arrayRes = output.components(separatedBy: " ")
                    //print(arrayRes)
                    var count = 0
                    for i in arrayRes {
                        count+=1
                        if i.contains("CPU") && arrayRes[count+1].contains("temperature") {
                            //print("CPU Die Temperature: \(arrayRes[count+2]) C")
                            cpuTemp = arrayRes[count+2]
                        }
                        if i.contains("GPU") && arrayRes[count+1].contains("temperature") {
                            //print("GPU Die Temperature: \(arrayRes[count+2]) C")
                            gpuTemp = arrayRes[count+2]
                        }
                        if i.contains("frequency") && arrayRes[count+3].contains("nominal") && arrayRes[count-3].contains("System") {
                            //print("CPU Frequency: \(arrayRes[count+5].dropFirst()) Mhz")
                            freq = String(arrayRes[count+5].dropFirst())
                        }
                        
                    
                    }
                    //https://stackoverflow.com/questions/46376823/ios-swift-get-the-current-local-time-and-date-timestamp
                    let timestamp = NSDate().timeIntervalSince1970
                    let myTimeInterval = TimeInterval(timestamp)
                    let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                    //https://stackoverflow.com/questions/31416975/cannot-assign-a-value-of-type-nsdate-to-a-value-of-type-string
                    var formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm:ss"
                    currentTime = formatter.string(from: time as Date)
                    
                }).padding()
            } else {
                Text("Admin needed")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)//https://www.reddit.com/r/SwiftUI/comments/hnfwuh/a_menubar_example_with_popover_window_using/fygojkd?utm_source=share&utm_medium=web2x for fix.
            .onAppear {
                var context = LAContext()
                let reason = "Security"
                context.evaluatePolicy(
                    // .deviceOwnerAuthentication allows
                    // biometric or passcode authentication
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                ) { success, error in
                    if success {
                        verified = true
                        
                        // Handle successful authentication
                        
                    } else {
                        verified = false
                        // Handle LAError error
                        
                    }
                }
                
            }
    }
}
    
    
    
    func updateStatusBarTitle(title: String){
        AppDelegate.shared.statusBarItem?.button?.title = title
    }


   


    

