//
//  PrimAlgorithmViewController.swift
//  PrimAlgorithm
//
//  Created by Potari Gabor on 2016. 12. 11..
//  Copyright © 2016. Potari Gabor. All rights reserved.
//

import UIKit
import MapKit

enum MapState {
    case Normal
    case Add
}

class Edge {
    var weight: Double = Double.infinity
    var to: Node
    
    init(weight: Double, to: Node) {
        self.weight = weight
        self.to = to
    }
}

class Node {
    var id: Int
    var coordinate: CLLocationCoordinate2D
    var edges: [Edge]
    
    init(id: Int, coordinate: CLLocationCoordinate2D, edges: [Edge]) {
        self.id = id
        self.coordinate = coordinate
        self.edges = edges
    }
}

class PrimAlgorithmViewController : UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var makeStepItem: UIBarButtonItem!
    var isEdge = true
    
    private var mapState : MapState = .Normal
    var newEdgeItem: UIBarButtonItem!
    
    private var nodes: [Node] = []
    private var d: [Double] = []
    private var p: [Node?] = []
    private var minQ: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Prim algorithm"
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
        newEdgeItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEdge))
        
        toolbar.items?[0] = newEdgeItem
        map.delegate = self
        
    }
    
    
    func mapTapped(gestureReconizer: UITapGestureRecognizer) {
        
        switch mapState {
        case .Normal:
            break
        case .Add:
            let location = gestureReconizer.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            updateNodes(coordinate: coordinate)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        }
    }
    
    func randomNumber(range: Range<Int>) -> Int {
        let min = range.lowerBound
        let max = range.upperBound
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }

    func updateNodes(coordinate : CLLocationCoordinate2D) {
        
        let newNode = Node(id: nodes.count, coordinate: coordinate, edges: [])
        
        if nodes.count == 0 {
            nodes.append(newNode)
            d.append(0.0)
            minQ.append(0)
            p.append(nil)
            return
        }
        
        nodes.forEach {
            node in
            let doIWantToAddNewEdge = randomNumber(range: Range<Int>(uncheckedBounds: (lower:0, upper:2)))
            if doIWantToAddNewEdge > 0 {
                let distance = MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordinate), MKMapPointForCoordinate(node.coordinate));
                newNode.edges.append(Edge( weight: distance, to: node))
                node.edges.append(Edge( weight: distance, to: newNode))
                
                let polyline = MKPolyline(coordinates: [node.coordinate, coordinate], count: 2)
                self.map.add(polyline)
            }
        }
        
        p.append(nil)
        d.append(Double.infinity)
        minQ.append(0)
        nodes.append(newNode)
    }
    
    func isEnded() -> Bool {
        let c = minQ.filter {
            $0 == 0
        }
        
        return (c.count == 0)
    }
    
    func makeStep(_ sender: Any) {

        isEdge = false
        if isEnded() {
           return
        }
        
        let minNodeValues = d.filter {
            distance in
            minQ[d.index(of: distance)!] == 0
        }
      
        let minNodeId = d.index(of: minNodeValues.min()!)
        
        let actNode = nodes.first{
            node in
            node.id == minNodeId
        }
        
        if minNodeId != 0 {
            let polyline = MKPolyline(coordinates: [p[(actNode!.id)]!.coordinate, actNode!.coordinate], count: 2)
            self.map.add(polyline)
        }

        actNode!.edges.forEach {
            edge in
            let neighbour = edge.to
            if minQ[neighbour.id] == 0 && edge.weight < d[neighbour.id] {
                d[neighbour.id] = edge.weight
                p[neighbour.id] = actNode
            }
        }
        
        minQ[actNode!.id] = 1
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        if isEdge {
            polylineRenderer.strokeColor = .black
            polylineRenderer.lineWidth = 0.5
        } else {
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 2.5
        }
        
        return polylineRenderer
    }
    
    func addEdge(_ sender: Any) {
        switch  self.mapState {
        case .Normal:
            newEdgeItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(addEdge))
            mapState = .Add
            break
        case .Add:
            mapState = .Normal
            newEdgeItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addEdge))
        }
        
        toolbar.items?[0] = newEdgeItem
    }
    
    private func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "node")
        
        pinAnnotationView.pinTintColor = .purple
        pinAnnotationView.isDraggable = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        
        let deleteButton = UIButton(type: .custom) as UIButton
        deleteButton.frame.size.width = 44
        deleteButton.frame.size.height = 44
        deleteButton.backgroundColor = UIColor.red
        pinAnnotationView.tag = map.annotations.count
        pinAnnotationView.leftCalloutAccessoryView = deleteButton
        
        return pinAnnotationView
    }
}
