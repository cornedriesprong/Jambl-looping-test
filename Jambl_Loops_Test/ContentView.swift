//
//  ContentView.swift
//  Jambl_Loops_Test
//
//  Created by Corné Driesprong on 31/08/2023.
//

import SwiftUI

let maxLength = 64.0

struct ContentView: View {
    @State private var loop = (start: 0.0, end: 63.0)
    @State private var progress = 0.0
    
    private let lengths: [Double] = [64, 32, 16, 8]
    private let displayLink = DisplayLink()

    var body: some View {
        VStack {
            ForEach(lengths, id: \.self) { l in
                HStack {
                    Text("\(Int(l))")
                        .frame(width: 21)
                    CustomSlider(
                        progress: $progress,
                        loop: $loop,
                        length: l)
                }
            }
            Text("Progress: \(Int(progress))")
            Text("Loop start: \(Int(loop.start))")
                .foregroundColor(.blue)
            Text("Loop end: \(Int(loop.end))")
                .foregroundColor(.red)
        }
        .padding()
        .onAppear {
            displayLink.start {
                progress += 0.1
            }
        }
    }
}

struct CustomSlider: View {
    @Binding var progress: Double
    @Binding var loop: (start: Double, end: Double)
    let length: Double
    let thumbHeight = CGFloat(30.0)
    let thumbWidth = CGFloat(3.0)
    
    var modStart: Double {
        return loop.start.truncatingRemainder(dividingBy: length)
    }
    
    var modEnd: Double {
        return loop.end.truncatingRemainder(dividingBy: length)
    }
    
    var body: some View {
        return GeometryReader { geometry in
            let width = geometry.size.width + thumbWidth
            let modProgress = (progress + modStart).truncatingRemainder(dividingBy: modEnd)
            let progressX = (modProgress / length) * width
                                     
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(
                        width: geometry.size.width,
                        height: 3)
                
                if modStart < modEnd {
                    Rectangle()
                        .frame(
                            width: (width / length) * min(length, modEnd - modStart))
                        .offset(x: (width / length) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                } else if modStart > modEnd {
                    Rectangle()
                        .frame(
                            width: (width / length) * min(length, length - modStart))
                        .offset(x: ((geometry.size.width - thumbWidth) / length) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                    
                    Rectangle()
                        .frame(
                            width: (width / length) * min(length, modEnd))
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                }

                // start loop indicator
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modStart) / length) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                var start = Double(gesture.location.x / width) * length
                                if modStart < 0 {
                                    start = 0
                                } else if modStart >= length {
                                    start = length 
                                } else if modStart >= modEnd {
                                    start = modEnd
                                }
                                loop.start = start
                            })
                    )
                
                // end loop indicator
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modEnd) / length) * width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                var end = Double(gesture.location.x / width) * length
                                if modEnd <= 0 {
                                    end = 0
                                } else if modEnd >= length {
                                    end = length
                                } else if modEnd <= modStart {
                                    end = modStart
                                }
                                loop.end = end
                            })
                    )
               
                // progress indicator
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .contentShape(Rectangle())
                    .offset(x: progressX)
            }
        }.frame(height: 30, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
