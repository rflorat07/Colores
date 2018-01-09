//
//  ViewController.swift
//  Colores
//
//  Created by Roger Florat on 09/01/18.
//  Copyright © 2018 Roger Florat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Outlet
    @IBOutlet weak var btnSwitch: UIButton!
    @IBOutlet weak var imgKnobBase: UIImageView!
    @IBOutlet weak var imgKnob: UIImageView!
    
    private var deltaAngle: CGFloat?
    private var startTransform: CGAffineTransform?
    
    // el punto de arriba
    private var setPointAngle = Double.pi / 2
    
    // establecemos nuestros lìmites tomando como referencia un àngulo de 30 grados
    private var maxAngle = 7 * Double.pi / 6
    private var minAngle = 0 - ( Double.pi / 6 )
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgKnob.isHidden = true
        imgKnobBase.isHidden = true
        imgKnob.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnSwitch.setImage(#imageLiteral(resourceName: "img_switch_off"), for: .normal)
        btnSwitch.setImage(UIImage(named: "img_switch_on"), for: .selected)
    }
    
    @IBAction func btnSwitchPressed(_ sender: UIButton) {
        btnSwitch.isSelected = !btnSwitch.isSelected
        
        if btnSwitch.isSelected {
            imgKnob.isHidden = false
            imgKnobBase.isHidden = false
            resetKnob()
        } else {
            view.backgroundColor = UIColor(hue: 0.5, saturation: 0, brightness: 0.2, alpha: 1.0)
            imgKnob.isHidden = true
            imgKnobBase.isHidden = true
        }
    }
    
    func resetKnob() {
        view.backgroundColor = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.75, alpha: 1.0)
        imgKnob.transform = CGAffineTransform.identity
        setPointAngle = Double.pi / 2
    }
    
    private func touchIsInKnobWithDistance(distance: CGFloat) -> Bool {
        if distance > (imgKnob.bounds.height / 2 ) { // estamos calculando el radio
            return false
        } else {
            return true
        }
    }
    
    // teorema de pitàgoras
    private func calculateDistanceFromCenter(_ point: CGPoint) -> CGFloat {
        let center = CGPoint(x: imgKnob.bounds.size.width / 2.0 , y: imgKnob.bounds.size.height / 2.0)
        let dx = point.x - center.x
        let dy = point.y - center.y
        
        return sqrt((dx * dx) + (dy * dy))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let delta = touch.location(in: imgKnob)
            let dist = calculateDistanceFromCenter(delta)
            if touchIsInKnobWithDistance(distance: dist){
                startTransform = imgKnob.transform
                let center = CGPoint(x: imgKnob.bounds.size.width / 2.0 , y: imgKnob.bounds.size.height / 2.0)
                let deltaX = delta.x - center.x
                let deltaY = delta.y - center.y
                deltaAngle = atan2(deltaY, deltaX)
            }
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == imgKnob {
                deltaAngle = nil
                startTransform = nil
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            let deltaAngle = deltaAngle,
            let startTransform = startTransform,
            touch.view == imgKnob{
            let position = touch.location(in: imgKnob)
            let dist = calculateDistanceFromCenter(position)
            if touchIsInKnobWithDistance(distance: dist){
                // vamos a calcular el àngulo segùn arrastramos
                let center = CGPoint(x: imgKnob.bounds.size.width / 2.0, y: imgKnob.bounds.size.height / 2.0)
                let deltaX = position.x - center.x
                let deltaY = position.y - center.y
                let angle = atan2(deltaY, deltaX)
                
                // y calculamos la distancia con el anterior
                let angleDif = deltaAngle - angle
                let newTransform = startTransform.rotated(by: -angleDif) // para la imagen
                let lastSetPointAngle = setPointAngle
                
                //comprovamos que nonos hemos pasado de los lìmites mìnimos y màximo
                //Al anterior le sumamos lo que nos hemos movido
                setPointAngle = setPointAngle + Double(angleDif)
                if setPointAngle > minAngle && setPointAngle <= maxAngle {
                    //si esta dentro de los màrgenes, cambiamos el color
                    view.backgroundColor = UIColor(hue: colorValueFromAngle(angle: setPointAngle), saturation: 0.75, brightness: 0.75, alpha: 1.0)
                    imgKnob.transform = newTransform
                    self.startTransform = newTransform
                } else {
                    // si se pasa lo dejamos en el lìmite
                    setPointAngle = lastSetPointAngle
                }
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    
    private func colorValueFromAngle(angle: Double) -> CGFloat {
        let hueValue = (angle - minAngle) * (360 / maxAngle - minAngle)
        return CGFloat(hueValue / 360)
    }
    
}

