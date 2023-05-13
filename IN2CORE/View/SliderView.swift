//
//  SliderView.swift
//  IN2CORE
//
//  Created by Lukas Budac on 13/05/2023.
//

import Foundation
import SwiftUI

struct SliderView: View {
    
    @ObservedObject var viewModel: VideoViewModel
    @State var lastCoordinateValue: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { gr in
            let dimensions = Dimensions(gr: gr, progress: viewModel.progress)

            ZStack {
                progressBar(dimensions)
                
                ForEach(0..<(viewModel.video?.inOuts.count ?? 0), id: \.self) { index in
                    HStack {
                        inOut(dimensions, index: index)
                        Spacer().frame(minWidth: 0)
                    }
                    .frame(width: dimensions.progressWidth)
                }
                
                HStack {
                    thumb(dimensions)
                    Spacer()
                }
            }
        }
    }
}

extension SliderView {
    
    struct Dimensions {
      
        let sliderRange: ClosedRange<Double> = 0...100
        
        let progress: Double
        
        let thumbHeight: CGFloat
        let thumbWidth: CGFloat
        let thumbRadius: CGFloat
        
        let minValue: CGFloat = 0
        let maxValue: CGFloat
        var sliderVal: CGFloat { (progress - lower) * scaleFactor + minValue }
        
        let progressWidth: CGFloat
        let progressHeight: CGFloat
        let progressRadius: CGFloat
        
        var scaleFactor: CGFloat { (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound) }
        var lower: CGFloat { sliderRange.lowerBound }
        
        init(gr: GeometryProxy, progress: Double) {
            self.progress = progress
            thumbHeight = gr.size.height
            thumbWidth = gr.size.height * 1.1
            thumbRadius = gr.size.height * 0.05
            progressRadius = gr.size.height * 0.05
            progressHeight = gr.size.height * 0.4
            maxValue = gr.size.width - thumbWidth
            progressWidth = gr.size.width - thumbWidth
        }
        
    }
    
    private func progressBar(_ dimensions: Dimensions) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: dimensions.progressWidth, height: dimensions.progressHeight)
            .overlay(
                RoundedRectangle(cornerRadius: dimensions.progressRadius)
                    .stroke(lineWidth: 1)
            )
            .onTapGesture(perform: { point in
                let width = dimensions.progressWidth
                let x: CGFloat = point.x.inRangeOrEqualTo(min: 0, max: width)
                let percent = (x / width) * 100
                viewModel.seekTo(percentage: percent)
            })
    }
    
    private func inOut(_ dimensions: Dimensions, index: Int) -> some View {
        HStack {
            Rectangle()
                .foregroundColor(.green.opacity(viewModel.inOut == viewModel.video!.inOuts[index] ? 1 : 0.2))
                .frame(
                    width: (dimensions.progressWidth)*(viewModel.video!.inOuts[index].end - viewModel.video!.inOuts[index].start),
                    height: dimensions.progressHeight*0.7
                )
                .offset(x: (dimensions.progressWidth)*viewModel.video!.inOuts[index].start)
                .onTapGesture(perform: { point in
                    viewModel.inOut = viewModel.video!.inOuts[index]
                })
            
            Spacer()
                .frame(minWidth: 0)
        }
    }
    
    private func thumb(_ dimensions: Dimensions) -> some View {
        RoundedRectangle(cornerRadius: dimensions.thumbRadius)
            .foregroundColor(.gray.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: dimensions.thumbRadius)
                    .stroke(lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: dimensions.thumbRadius)
                    .stroke(Color.blue, lineWidth: 1)
                    .frame(maxWidth: 1)
                    .padding(.top, dimensions.thumbHeight * 0.2)
                    .padding(.bottom, dimensions.thumbHeight * 0.2)
            )
            .frame(width: dimensions.thumbWidth, height: dimensions.thumbHeight)
            .offset(x: dimensions.sliderVal)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        if (abs(v.translation.width) < 0.1) {
                            self.lastCoordinateValue = dimensions.sliderVal
                        }
                        let progress: Double
                        if v.translation.width > 0 {
                            let nextCoordinateValue = min(dimensions.maxValue, self.lastCoordinateValue + v.translation.width)
                            progress = ((nextCoordinateValue - dimensions.minValue) / dimensions.scaleFactor) + dimensions.lower
                        } else {
                            let nextCoordinateValue = max(dimensions.minValue, self.lastCoordinateValue + v.translation.width)
                            progress = ((nextCoordinateValue - dimensions.minValue) / dimensions.scaleFactor) + dimensions.lower
                        }
                        viewModel.scrub(percentage: progress)
                    }
            )
    }
    
}

struct SliderView_Previews: PreviewProvider {
    
    static var previews: some View {
        SliderView(viewModel: VideoViewModel())
            .frame(maxHeight: 48)
    }
}
