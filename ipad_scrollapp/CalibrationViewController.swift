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
    class MyButton: UIButton{
        let x:Int
        let y:Int
        init(x:Int,y:Int,frame:CGRect){
            self.x = x
            self.y = y
            super.init(frame:frame)
        }
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Do any additional setup after loading the view.
        //timeInterval秒に一回update関数を動かす
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        for x in 0...1{
            for y in 0...6{
            //位置を変えながらボタンを作る
                let btn : UIButton = MyButton(
                    x:x,
                    y:y,
                    frame:CGRect(x: CGFloat(x)*100,y: CGFloat(y)*90,width: 80,height: 50))
                btn.setTitle("眉毛", for: .normal)
            //ボタンを押したときの動作
                btn.addTarget(self, action: #selector(self.pushed(mybtn:)), for: .touchUpInside)
            //見える用に赤くした
            btn.backgroundColor = UIColor.black
            //画面に追加
            view.addSubview(btn)
            }
        }
    }
    @objc func update() {
        DispatchQueue.main.async {
            self.tracking.backgroundColor = UIColor.white
        }
    }
    
    //ボタンが押されたときの動作
    @objc func pushed(mybtn : MyButton){
        //押されたボタンごとに結果が異なる
        print("button at (\(mybtn.x),\(mybtn.y)) is pushed")
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
