//
//  CalibrationViewController.swift
//  ipad_scrollapp
//
//  Created by miyata ginga on 2019/12/04.
//  Copyright © 2019 com.miyagin.ipad_scroll. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class CalibrationViewController: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet var tracking: UIView!
    @IBOutlet var sceneView: ARSCNView!
    //ウインクした場所を特定するために定義
    let userDefaults = UserDefaults.standard
    //Trackingfaceを使うための設定
    private let defaultConfiguration: ARFaceTrackingConfiguration = {
        let configuration = ARFaceTrackingConfiguration()
        return configuration
    }()
    
    // UIButtonを継承した独自クラス
    class callibrationButton: UIButton{
        let x:Int
        init(x:Int,frame:CGRect){
            self.x = x
            super.init(frame:frame)
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    let callibrationArr:[String]=["口左","口右","口上","口下","頰右","頰左","眉毛上","眉毛下","右笑い","左笑い","ノーマル","a","b"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        //timeInterval秒に一回update関数を動かす
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        createCallibrationButton()
    }
    @objc func update() {
        DispatchQueue.main.async {
            self.tracking.backgroundColor = UIColor.white
        }
    }
    private func createCallibrationButton(){
        for x in 0...12{
            let buttonXposition=0
            //位置を変えながらボタンを作る
            let btn : UIButton = callibrationButton(
                x:x,
                frame:CGRect(x: CGFloat(buttonXposition),y: CGFloat(x)*90,width: 80,height: 50))
            if(x<7){
                btn.frame=CGRect(x: CGFloat(buttonXposition),y: CGFloat(x)*90,width: 160,height: 50)
            }else{
                btn.frame=CGRect(x: CGFloat(buttonXposition+180),y: CGFloat(x-7)*90,width: 160,height: 50)
            }
            btn.setTitle(callibrationArr[x], for: .normal)
            //ボタンを押したときの動作
            btn.addTarget(self, action: #selector(self.pushed(mybtn:)), for: .touchUpInside)
            //見える用に赤くした
            btn.backgroundColor = UIColor.black
            //画面に追加
            view.addSubview(btn)
        }
    }
    
    //ボタンが押されたときの動作
    @objc func pushed(mybtn : callibrationButton){
        //押されたボタンごとに結果が異なる
        print("button at (\(mybtn.currentTitle!)) is pushed")
        mybtn.setTitle(mybtn.currentTitle!+"押した", for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           sceneView.session.run(defaultConfiguration)
           //NetWork.startConnection(to: "a")
       }
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           sceneView.session.pause()
           //NetWork.stopConnection()
       }
    
       func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else {
                return
            }
            print(faceAnchor.geometry.vertices[24][1],"24")
            print(faceAnchor.geometry.vertices[25][1],"25")
                // 認識していたら青色に
            DispatchQueue.main.async {
                //print(self.tableView.contentOffset.y)
                self.tracking.backgroundColor = UIColor.blue
            }
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
