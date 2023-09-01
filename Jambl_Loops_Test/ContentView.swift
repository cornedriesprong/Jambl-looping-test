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
                if progress >= loop.end {
                    progress = loop.start
                } else {
                    progress += 0.1
                }
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
    
    var blockWidth: CGFloat {
        return CGFloat(maxLength / length)
    }
    
    var modStart: Double {
        return loop.start.truncatingRemainder(dividingBy: length)
    }
    
    var modEnd: Double {
        return loop.end.truncatingRemainder(dividingBy: length)
    }
    
    var phaseIndicator: some View {
        VStack {
            Spacer()
            Rectangle()
                .foregroundColor(.purple)
                .frame(width: 2, height: thumbHeight * 1.5)
            Spacer()
        }
    }
    
    var blocks: some View {
        let numberOfBlocks = Int(maxLength / length)
        return HStack(spacing: 0) {
            ForEach(0..<numberOfBlocks) { _ in
                Rectangle()
                    .frame(width: thumbWidth, height: thumbHeight)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let segmentWidth = width / CGFloat(maxLength / length)
            
            let relativeStart = loop.start * (length / maxLength)
            let relativeEnd = loop.end * (length / maxLength)

            let startSegment = CGFloat(relativeStart) * segmentWidth / CGFloat(length)
            let endSegment = CGFloat(relativeEnd) * segmentWidth / CGFloat(length)

            
            ZStack(alignment: .leading) {
                blocks
                
                Rectangle()
                    .foregroundColor(.gray)
                    .frame(width: geometry.size.width, height: 3)
                
                phaseIndicator
                    .offset(x: CGFloat(progress / maxLength) * geometry.size.width)
                
                Rectangle()
                    .foregroundColor(.yellow)
                    .opacity(0.1)
                    .frame(width: endSegment - startSegment, height: thumbHeight)
                    .offset(x: startSegment)
                
                // start loop indicator
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .contentShape(Rectangle())
                    .offset(x: startSegment)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                let newValue = Double(gesture.location.x / geometry.size.width) * maxLength
                                loop.start = min(max(0, newValue), loop.end - 1.0) // Ensure there's at least 1 unit difference between start and end
                            })

                    )
                
                // end loop indicator
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: thumbWidth, height: thumbHeight)
                    .contentShape(Rectangle())
                    .offset(x: endSegment)
                    .gesture(
                        DragGesture()
                            .onChanged({ gesture in
                                let newValue = Double(gesture.location.x / geometry.size.width) * maxLength
                                loop.start = min(max(0, newValue), loop.end - 1.0) // Ensure there's at least 1 unit difference between start and end
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
