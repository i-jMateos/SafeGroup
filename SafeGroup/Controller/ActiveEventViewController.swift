//
//  ActiveEventViewController.swift
//  SafeGroup
//
//  Created by Jordi Mateos Manchado on 18/12/2020.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import SpriteKit
import ForceDirectedScene
import CoreBluetooth
import CoreLocation
import Firebase

class ActiveEventViewController: UIViewController {

    @IBOutlet weak var forceGraphView: SKView!
    
    var forcedGraph: DLForcedGraphView!
    var graphScene: DLGraphScene!
    
    var ownNode: MyNode!
    var nodes: [MyNode] = []
    var links: [MyLink] = []
    var nearbyPeers = [UInt: PPKPeer]()
    var peerNodes = [UInt: SKShapeNode]()
    var nextNodeIndex: Int = 0
    
    var event: Event!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        forcedGraph = DLForcedGraphView(frame: forceGraphView.bounds)
        forceGraphView.addSubview(forcedGraph)

        graphScene = self.forcedGraph.graphScene
        graphScene.delegate = self

        let edge = DLMakeEdge(0, 0)
        edge?.repulsion = 1100.0
        edge?.attraction = 0.07
        graphScene.add(edge)
        
        DispatchQueue.main.async {
            PPKController.enable(withConfiguration: "af27d1fd52024bba8dc866745ebda174", observer: self)
            PPKController.enableProximityRanging()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 13.0, *) {
            if (CBCentralManager().authorization != .allowedAlways) {   //System will automatically ask user to turn on iOS system Bluetooth if this returns false
                print("Bluetooth enabled")
            }
        } else {
            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
            
        }
    }
    
    func addNodeForPeer(peer: PPKPeer) {
        if checkPeerExists(peer) {
            updateColor(for: peer)
            return
        }
        
        let lastIndex: UInt = UInt(nearbyPeers.count + 1)
        nearbyPeers[lastIndex] = peer
        
        let edge = DLMakeEdge(0, lastIndex)
        edge?.repulsion = self.getRepulsionFor(peer.proximityStrength)
        edge?.attraction = self.getAttractionFor(peer.proximityStrength)
        edge?.unknownConnection = (peer.proximityStrength == .unknown)
        edge?.immediateConnection = (peer.proximityStrength == .immediate)
        
        graphScene.add(edge)
    }
    
    func checkPeerExists(_ peer: PPKPeer?) -> Bool {
        if let peer = peer, nearbyPeers.values.contains(peer) {
            return true
        }
        
        return false
    }
    
    func updateColor(for peer: PPKPeer?) {
        if !checkPeerExists(peer) {
            return
        }

        let index = nearbyPeers.keys.first
        var node: SKShapeNode? = nil
        if let index = index {
            node = peerNodes[index]
        }
        setColor(color(from: peer?.discoveryInfo), for: node, animated: true)
    }
    
    func color(from data: Data?) -> UIColor? {
        let random = {CGFloat(arc4random_uniform(255)) / 255.0}
        return UIColor(red: random(), green: random(), blue: random(), alpha: 1)
    }
    
    func setColor(_ color: UIColor?, for node: SKShapeNode?, animated: Bool) {
        if let color = color {
            node?.strokeColor = color
            node?.fillColor = color
        }

        if animated {
            let moveNode = SKAction.move(by: CGVector(dx: (ownNode.position.x - (node?.position.x ?? 0.0)) * 0.33, dy: (ownNode.position.y - (node?.position.y ?? 0.0)) * 0.33), duration: 0.25)
            let changeColor = SKAction.customAction(withDuration: 0.25, actionBlock: { node, elapsedTime in
                node.yScale = elapsedTime / 0.25 * 1.0
                node.xScale = elapsedTime / 0.25 * 1.0
            })

            node?.run(SKAction.group([moveNode, changeColor]))
        }

        updateStrokesForAllNodes()
    }
    
    func updateStrokesForAllNodes() {

        let highlightColor = UIColor.white

        var hasImmediatePeers = false
        nearbyPeers.forEach({ (index, peer) in
            var node: SKShapeNode? = nil
            node = peerNodes[index]
            
            if peer.proximityStrength == .immediate {
                node?.strokeColor = highlightColor
                hasImmediatePeers = true
            } else {
                if let fillColor = node?.fillColor {
                    node?.strokeColor = fillColor
                }
            }
        })

        ownNode.skNode.strokeColor = hasImmediatePeers ? highlightColor : ownNode.skNode.fillColor
    }
    
    func removeNode(for peer: PPKPeer?) {
        if !checkPeerExists(peer) {
            return
        }

        guard let index = nearbyPeers.keys.first else { return }
        guard let peerIndex = nearbyPeers.index(forKey: index) else { return }
        graphScene.remove(DLMakeEdge(0, index))
        peerNodes.removeValue(forKey: index)
        nearbyPeers.remove(at: peerIndex)

        updateStrokesForAllNodes()
    }

    func removeNodesForAllPeers() {
        nearbyPeers.forEach { (index, peer) in
            self.graphScene.remove(DLMakeEdge(0, index))
        }

        peerNodes.removeAll()
        nearbyPeers.removeAll()

        updateStrokesForAllNodes()
    }
    
    func updateProximityStrength(for peer: PPKPeer) {
        if !checkPeerExists(peer) {
            return
        }

        let index = nearbyPeers.keys.first

        let edge = DLMakeEdge(0, index ?? 0)
        edge?.repulsion = self.getRepulsionFor(peer.proximityStrength)
        edge?.attraction = self.getAttractionFor(peer.proximityStrength)
        edge?.unknownConnection = (peer.proximityStrength == .unknown)
        edge?.immediateConnection = (peer.proximityStrength == .immediate)
        graphScene.update(edge)

        updateStrokesForAllNodes()
    }
    
    private func createVertexNode() -> SKShapeNode? {
        let radius: CGFloat = 20.0

        let circlePath = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)

        let node = SKShapeNode()
        node.path = circlePath
        node.zPosition = 10
        node.name = "node"
//        node.alpha = 0.0

        node.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        node.physicsBody?.allowsRotation = false

//        let zoom = SKAction.fadeIn(withDuration: 0.25)
//        node.run(zoom)
        
        return node
    }
    
    private func configureShapeNode(node: SKShapeNode, atIndex index: Int) {
        if (index == 0) {
//            let transformNode: SKTransformNode = SKTransformNode()
//            transformNode.addChild(node)
//            transformNode.setScale(1.3)
            
            node.physicsBody = SKPhysicsBody(circleOfRadius: node.frame.size.width / 2)
            node.physicsBody?.isDynamic = false
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.charge = 5.5
            node.physicsBody?.linearDamping = 1.3
            node.physicsBody?.mass = node.physicsBody?.mass ?? 0.0
            node.position = CGPoint(x: 0, y: 0)
            
            node.constraints = [
                SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: self.forceGraphView.bounds.width)),
                SKConstraint.positionY(SKRange(lowerLimit: 0, upperLimit: self.forceGraphView.bounds.height))
            ]
            
            let label = SKLabelNode()
            label.fontName = "HelveticaNeue-Thin"
            label.verticalAlignmentMode = .center
            label.text = "me"
            node.addChild(label)
            
            ownNode = MyNode(skNode: node)
            node.fillColor = UIColor.red
            
            node.lineWidth = 2.0
        }
    }
    
    func createEventAlert(alert: EventAlert) {
        guard let alertDict = alert.dictionary else { return }
        
        db.collection("alerts").addDocument(data: alertDict) { (error) in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Success adding alert")
            }
        }
    }
    
    @IBAction func alertsButtonDidPressed(_ sender: Any) {
//        let peer = PPKPeer()
//        addNodeForPeer(peer: peer)
        guard let currentUser = User.currentUser else { return }
        
        let alertController = UIAlertController(title: "Enviar alerta", message: "Envia una alerta a tu guia si necesitas ayuda", preferredStyle: .actionSheet)
        
        let lostAlertAction = UIAlertAction(title: EventAlertType.lost.title, style: .default) { (action) in
            
            let latitude = CLLocationManager().location?.coordinate.latitude ?? 0
            let longitude = CLLocationManager().location?.coordinate.longitude ?? 0
            let location = Location(latitude: latitude, longitude: longitude)
            let alert = EventAlert.create(.lost, lastUserLocalation: location, lastUserDistanceMeters: nil, event: self.event, user: currentUser)
            
            self.createEventAlert(alert: alert)
        }
        
        let breakAlertAction = UIAlertAction(title: EventAlertType.needABreak.title, style: .default) { (action) in
            let alert = EventAlert.create(.needABreak, event: self.event, user: currentUser)
            
            self.createEventAlert(alert: alert)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }

        alertController.addAction(lostAlertAction)
        alertController.addAction(breakAlertAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addParticipantButtonPressed(_ sender: Any) {
        PPKController.startDiscovery(withDiscoveryInfo: "Hello".data(using: .utf8), stateRestoration: false)
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ActiveEventViewController: PPKControllerDelegate {
    func ppkControllerInitialized() {
      // ready to start discovering nearbys
        print("Ready to start discovering")
    }
    
    func peerDiscovered(_ peer: PPKPeer) {
        if let discoveryInfo = peer.discoveryInfo {
            let discoveryInfoString = String(data: discoveryInfo, encoding: .utf8)
            print("\(peer.peerID) is here with discovery info: \(discoveryInfoString)")
            
            self.addNodeForPeer(peer: peer)
        }
    }
    
    func peerLost(_ peer: PPKPeer) {
        print("\(peer.peerID) is no longer here")
        
        removeNode(for: peer)
    }
    
    func proximityStrengthChanged(for peer: PPKPeer) {
        self.updateProximityStrength(for: peer)
        if (peer.proximityStrength.rawValue > PPKProximityStrength.weak.rawValue) {
          print("\(peer.peerID) is in range, do something with it")
        }
        else {
          print("\(peer.peerID) is not yet in range")
        }
    }
}

//extension ActiveEventViewController: SKSceneDelegate {
//    func update(_ currentTime: TimeInterval, for scene: SKScene) {
////        fdGraph.update()
//    }
//
//    func didApplyConstraints(for scene: SKScene) {
////        var path: UIBezierPath
////        for link in links {
////            guard let src = link.sourceSKNode else { return }
////            guard let dest = link.destinationSKNode else { return }
////            let lineNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 10, height: 10), cornerRadius: 0)
////            path = UIBezierPath()
////            path.move(to: src.position)
////            path.addLine(to: dest.position)
////
////            lineNode.path = path.cgPath
////        }
//    }
//}

extension ActiveEventViewController: DLGraphSceneDelegate {
    func tap(onVertex vertex: SKNode!, at index: UInt) {
        
    }
    
    func configureVertex(_ vertex: SKShapeNode!, at index: UInt) {
        if (index == 0) {
            //            let transformNode: SKTransformNode = SKTransformNode()
            //            transformNode.addChild(node)
            //            transformNode.setScale(1.3)
            
            vertex.physicsBody = SKPhysicsBody(circleOfRadius: vertex.frame.size.width / 2)
            vertex.physicsBody?.isDynamic = false
            vertex.physicsBody?.affectedByGravity = false
            vertex.physicsBody?.charge = 5.5
            vertex.physicsBody?.linearDamping = 1.3
            vertex.physicsBody?.mass = vertex.physicsBody?.mass ?? 0.0
            vertex.position = CGPoint(x: 0, y: 0)
            
            //            node.constraints = [
            //                SKConstraint.positionX(SKRange(lowerLimit: 0, upperLimit: self.forceGraphView.bounds.width)),
            //                SKConstraint.positionY(SKRange(lowerLimit: 0, upperLimit: self.forceGraphView.bounds.height))
            //            ]
            
            let label = SKLabelNode()
            label.fontName = "HelveticaNeue-Thin"
            label.fontSize = 14
            label.verticalAlignmentMode = .center
            label.text = "yo"
            vertex.addChild(label)
            
            ownNode = MyNode(skNode: vertex)
            vertex.fillColor = UIColor.red
        } else {
            let peer = nearbyPeers[index]
            peerNodes[index] = vertex
            let random = {CGFloat(arc4random_uniform(255)) / 255.0}
            let color = UIColor(red: random(), green: random(), blue: random(), alpha: 1)
            vertex.fillColor = color
        }
        
        vertex.lineWidth = 2.0
    }
}

extension ActiveEventViewController {
    func getRepulsionFor(_ proximityStrength: PPKProximityStrength) -> CGFloat {
        var repulsion: CGFloat
        switch proximityStrength {
        case .extremelyWeak:
            repulsion = 2500.0
        case .weak:
            repulsion = 2000.0
        case .medium:
            repulsion = 1500.0
        case .strong:
            repulsion = 1100.0
        case .immediate:
            repulsion = 700.0
        default:
            repulsion = 1500.0
        }
        
        return repulsion
    }
    
    func getAttractionFor(_ proximityStrength: PPKProximityStrength) -> CGFloat {
        var attraction: CGFloat
        switch proximityStrength {
        case .extremelyWeak:
            attraction = 0.025
        case .weak:
            attraction = 0.03
        case .medium:
            attraction = 0.05
        case .strong:
            attraction = 0.07
        case .immediate:
            attraction = 0.12
        default:
            attraction = 0.05
        }
        
        return attraction
    }
}

extension ActiveEventViewController: UIAlertViewDelegate {
    
}
