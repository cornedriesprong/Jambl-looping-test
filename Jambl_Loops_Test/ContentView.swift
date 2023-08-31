//
//  ContentView.swift
//  Jambl_Loops_Test
//
//  Created by Corné Driesprong on 31/08/2023.
//

import SwiftUI

let maxLength = 64.0

struct ContentView: View {
    @State private var loop = (start: 0.0, end: 50.0)
    
    private let lengths: [Double] = [64, 48, 32, 12]

    var body: some View {
        VStack {
            ForEach(lengths, id: \.self) { l in
                HStack {
                    Text("\(Int(l))")
                        .frame(width: 21)
                    CustomSlider(loop: $loop, length: l)
                }
            }
            Text("Loop start: \(Int(loop.start))")
                .foregroundColor(.blue)
            Text("Loop end: \(Int(loop.end))")
                .foregroundColor(.red)
        }
        .padding()
    }
}

struct CustomSlider: View {
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
                        width: (geometry.size.width / maxLength) * length,
                        height: 3)
                
                if modStart < modEnd {
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / maxLength) * min(length, modEnd - modStart))
                        .offset(x: (geometry.size.width / maxLength) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                } else {
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / maxLength) * min(length, length - modStart))
                        .offset(x: (geometry.size.width / maxLength) * modStart)
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                    
                    Rectangle()
                        .frame(
                            width: (geometry.size.width / maxLength) * min(length, modEnd))
                        .foregroundColor(.yellow)
                        .opacity(0.1)
                }

                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 3, height: thumbSize)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modStart) / maxLength) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                loop.start = Double(gesture.location.x / geometry.size.width) * 100.0
                                loop.start = loop.start < 0 ? 0 : loop.start > length ? length : loop.start
                            })
                    )
                
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 3, height: thumbSize)
                    .contentShape(Rectangle())
                    .offset(x: CGFloat((modEnd) / maxLength) * geometry.size.width)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                loop.end = Double(gesture.location.x / geometry.size.width) * 100.0
                                loop.end = loop.end < 0 ? 0 : loop.end > length ? length : loop.end
                            })
                    )
            }
        }.frame(height: 30, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
