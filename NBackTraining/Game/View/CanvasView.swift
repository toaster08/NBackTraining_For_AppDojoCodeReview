import SwiftUI
import PencilKit
import Vision
import CoreML

import ComposableArchitecture

struct CanvasView: UIViewRepresentable {
    let canvas: PKCanvasView
    
    func makeUIView(context: Context) -> some UIView {
        canvas.backgroundColor = .black
        canvas.drawingPolicy = .anyInput
        canvas.becomeFirstResponder()
        canvas.tool = PKInkingTool(.monoline, color: .white, width: 10)
        return canvas
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func reset() {
        canvas.drawing = PKDrawing()
    }
}
