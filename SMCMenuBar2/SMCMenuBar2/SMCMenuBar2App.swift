//
//  SMCMenuBar2App.swift
//  SMCMenuBar2
//
//  Created by Aaron Beckley on 4/15/24.
//
//https://stackoverflow.com/questions/76824753/how-can-i-add-a-searchbar-in-menubarextra-with-swiftui
//https://stackoverflow.com/questions/58613503/how-to-make-list-with-single-selection-with-swiftui
//https://www.simpleswiftguide.com/swiftui-textfield-complete-tutorial/
//https://stackoverflow.com/questions/49508817/update-element-in-array


import SwiftUI
import Charts
@main
struct swiftui_menu_barApp: App {
    @State var currentNumber: String = "1"
    
    @State private var showingPopover = false
    
    var body: some Scene {
        // Remove this
        // WindowGroup {
        //     ContentView()
        // }
        MenuBarExtra(currentNumber, systemImage: "thermometer.sun.circle.fill") {
            //
            
            TheMainView().padding()
            
            
            Divider()
           /* Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q") */
        }.menuBarExtraStyle(.window) // open item as popover window //This is needed for Textfield
    }
}

func TemperatureCPU() -> String {
    var temp = Double()
    do {
        try SMCKit.open()
        temp = try SMCKit.temperature(FourCharCode(fromStaticString: "TC0F"))
        SMCKit.close()
    } catch {
        temp = 0.0
    }
    return String(temp)
}
func TemperatureGPU() -> String {
    var temp = Double()
    do {
        try SMCKit.open()
        temp = try SMCKit.temperature(FourCharCode(fromStaticString: "TG0P"))
        SMCKit.close()
    } catch {
        temp = 0.0
    }
    return String(temp)
}
func BrandCPU() -> String {
    //list CPU type
    var size = 0
    sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
    var machine = [CChar](repeating: 0,  count: size)
    sysctlbyname("machdep.cpu.brand_string", &machine, &size, nil, 0)
    return String(cString: machine)
}
//Need way to get the current mhz in swift without sudo
func MHZCPU() -> String {
    var freq = 0
    var size = MemoryLayout.size(ofValue: freq)
    sysctlbyname("hw.cpufrequency", &freq, &size, nil, 0)
    return String(freq/1000000)
}



struct TempData: Identifiable {
    
    
    var time = String()
    var temp = Double()
    var id: String { time }
    
}




struct TheMainView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var tempCPU = TemperatureCPU()
    @State var tempGPU = TemperatureGPU()
    @State var CPU = BrandCPU()
    //@State var CPUSpeed = MHZCPU()
    //@State var CPUtemps = [String]()
    //@State var GPUtemps = [String]()
    @State var cpuData = [TempData]()
                      
    @State var gpuData = [TempData]()
    @State var count = 0
    
    @State var enableGraph = true
    @State var CPUminmax = [Double()]
    @State var GPUminmax = [Double()]
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(CPU)
                Spacer()
                Button(action: {
                    // What to perform
                    enableGraph.toggle()
                }) {
                    // How the button looks like
                    Text("Graphs")
                }
            }
            //Text("Clock: \(CPUSpeed) Mhz")
            Text("CPU: \(tempCPU) C")
            Text("GPU: \(tempGPU) C")
            if enableGraph {
                if CPUminmax.max() != CPUminmax.min() {
                    Chart {
                        ForEach(cpuData) { data in
                            LineMark(x: .value("Time", data.time),
                                     y: .value("CPU Temp", data.temp))
                        }
                    }.chartYScale(domain: [CPUminmax.min() ?? 40, CPUminmax.max() ?? 99])
                } else {
                    Chart {
                        ForEach(cpuData) { data in
                            LineMark(x: .value("Time", data.time),
                                     y: .value("CPU Temp", data.temp))
                        }
                    }.chartYScale(domain: [40, 99])
                }
                if GPUminmax.max() != GPUminmax.min() {
                    
                    Chart {
                        ForEach(gpuData) { data in
                            LineMark(x: .value("Time", data.time),
                                     y: .value("GPU Temp", data.temp))
                        }
                    }.chartYScale(domain: [GPUminmax.min() ?? 40, GPUminmax.max() ?? 99])
                } else {
                    Chart {
                        ForEach(gpuData) { data in
                            LineMark(x: .value("Time", data.time),
                                     y: .value("GPU Temp", data.temp))
                        }
                    }.chartYScale(domain: [40, 99])
                }
            }
            
            
            
           
        }.onReceive(timer, perform: { _ in
            tempCPU = TemperatureCPU()
            tempGPU = TemperatureGPU()
            
            
            //cpuData.append(TempData(time: String(currentDateTime), temp: tempCPU))
            if enableGraph {
                let date = Date()
                let dateFormatter = DateFormatter()
                //dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .long
                 
                cpuData.append(TempData(time: String(dateFormatter.string(from: date).dropLast(7)), temp: Double(tempCPU) ?? 40.0))
                gpuData.append(TempData(time: String(dateFormatter.string(from: date).dropLast(7)), temp: Double(tempGPU) ?? 40.0))
                CPUminmax.append(Double(tempCPU) ?? 40.0)
                GPUminmax.append(Double(tempGPU) ?? 40.0)
                //print(CPUminmax)
                //print(GPUminmax)
                if count > 4 {
                    cpuData = Array(cpuData.dropFirst(1))
                    gpuData = Array(gpuData.dropFirst(1))
                    CPUminmax = Array(CPUminmax.dropFirst(1))
                    GPUminmax = Array(GPUminmax.dropFirst(1))
                } else {
                    count+=1
                }
            }
            
            
            //CPUSpeed = MHZCPU()
        })
    }

}

