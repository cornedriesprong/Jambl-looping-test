//
//  ContentView.swift
//  Jambl_Loops_Test
//
//  Created by Corné Driesprong on 31/08/2023.
//

import SwiftUI

let maxLength = 64.0

struct ContentView: View {
    @State private var loop = (start: 0.0, end: 64.0)
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
                progress = ((progress + 0.1) + loop.start)
                    .truncatingRemainder(dividingBy: loop.end - loop.start)
            }
        }
    }
}

struct CustomSlider: View {
    @Binding var progress: Double
    @Binding var loop: (start: Double, end: Double)
    let length: Double
    let thumbSize = CGFloat(30.0)
    
    var modStart: Double {
        return loop.start.truncatingRemainder(dividingBy: length)
    }
    
    var modEnd: Double {
        return loop.end.truncatingRemainder(dividingBy: length)
    }

    var body: some View {
//        let width = UIScreen.main.bounds.width - thumbSize

        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(
                        width: geometry.size.width,
                        height: 3)
                
                if modStart < modEnd {
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / length) * min(length, modEnd - modStart))
                        .offset(x: (geometry.size.width / length) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                } else if modStart > modEnd {
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / length) * min(length, length - modStart))
                        .offset(x: (geometry.size.width / length) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                    
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / length) * min(length, modEnd))
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                }

                // start loop indicator
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 3, height: thumbSize)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modStart) / length) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                loop.start = Double(gesture.location.x / geometry.size.width) * length
                                if modStart < 0 {
                                    loop.start = 0
                                } else if modStart > modEnd {
                                    loop.start = modEnd
                                }
                            })
                    )
                
                // end loop indicator
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 3, height: thumbSize)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modEnd) / length) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                loop.end = Double(gesture.location.x / geometry.size.width) * length
                                if modEnd < 0 {
                                    loop.end = 0
                                } else if modEnd < modStart {
                                    loop.end = modStart
                                }
                            })
                    )
                
                // progress indicator
                Rectangle()
                    .foregroundColor(.black)
                    .frame(width: 3, height: thumbSize)
                    .contentShape(Rectangle())
                    .offset(x: (geometry.size.width / CGFloat(length)) * progress.truncatingRemainder(dividingBy: modEnd))
            }
        }.frame(height: 30, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
