//
//  DrawingAssistant.swift
//  062_path
//
//  Created by Oleg Kolomyitsev on 29/07/2018.
//  Copyright © 2018 Oleg Kolomyitsev. All rights reserved.
//

import UIKit

class DrawingAssistant: IDrawingAssistant {
    
    // MARK: - Memory Management
    
    let nodalPoints: PointsVector
    let visiblePointsMatrix: VisiblePointsMatrix

    init(_ nodalPoints: PointsVector,
         _ visiblePointsMatrix: VisiblePointsMatrix) {
        self.nodalPoints = nodalPoints
        self.visiblePointsMatrix = visiblePointsMatrix
    }
    
    // MARK: - IDrawingAssistant
    
    func drawAllPoints(on layer: CAShapeLayer) {
        func getBezierPath(_ points: PointsVector) -> UIBezierPath {
            let path = UIBezierPath()
            let squres = points.map { CGRect(squareInCenter: $0, size: Constants.Drawing.Point.Size.`default`)}
            let paths = squres.map { UIBezierPath(ovalIn: $0) }
            paths.forEach{ path.append($0) }
            
            return path
        }
        
        layer.path = getBezierPath(nodalPoints).cgPath
    }
    
    func draw(route: [Vertex], on layer: CAShapeLayer, useVisible: Bool) {
        precondition(!route.isEmpty, "Route should not be empry")
        
        func getNodalBezierPath(_ route: [Vertex]) -> UIBezierPath {
            let routePoints = route.map { nodalPoints[$0] }
            let path = UIBezierPath()
            path.move(to: routePoints.first!)
            routePoints[1...].forEach{ path.addLine(to: $0) }
            
            return path
        }
        
        func getVisibleBezierPath(_ route: [Vertex]) -> UIBezierPath {
            let path = UIBezierPath()
            let paths: [UIBezierPath] = zip(route.dropLast(), route.dropFirst()).map {
                let visiblePoints = visiblePointsMatrix[$0.0][$0.1]
                let path = UIBezierPath()
                let terminatedPoints = zip(visiblePoints.dropLast(), visiblePoints.dropFirst())
                terminatedPoints.forEach { path.addLine(from: $0.0, to: $0.1) }
                return path
            }
            paths.forEach{ path.append($0) }
            
            return path
        }
        
        layer.path = useVisible ? getVisibleBezierPath(route).cgPath : getNodalBezierPath(route).cgPath
    }

    func highlight(vertex: Vertex, type: VertexType, on layer: CAShapeLayer) {
        func getBezierPath(_ vertex: Vertex) -> UIBezierPath {
            let point = nodalPoints[vertex]
            var size: CGFloat {
                switch type {
                case .start: return Constants.Drawing.Point.Size.start
                case .final: return Constants.Drawing.Point.Size.final
                }
            }
            let rect = CGRect(squareInCenter: point, size: size)
            let path = UIBezierPath(ovalIn: rect)
            
            return path
        }
        
        layer.path = getBezierPath(vertex).cgPath
    }
}
