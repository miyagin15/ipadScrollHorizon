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
    @IBAction func goToVeticalScroll(_ sender: Any) {
        let verticalViewController = self.storyboard?.instantiateViewController(withIdentifier: "VerticalViewController") as! VerticalViewController
        verticalViewController.modalPresentationStyle = .fullScreen
        self.present(verticalViewController, animated: true, completion: nil)
    }
    @IBAction func goToHorizonalScroll(_ sender: Any) {
        let horizonalViewController = self.storyboard?.instantiateViewController(withIdentifier: "HorizonalViewController") as! ViewController
        horizonalViewController.modalPresentationStyle = .fullScreen
        self.present(horizonalViewController, animated: true, completion: nil)
    }
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
    let callibrationArr:[String]=["口左","口右","口上","口下","頰右","頰左","眉上","眉下","右笑","左笑","普通","a","b"]
    var callibrationPosition:[Float]=[0,0,0,0,0,0,0,0,0,0,0,0,0]

    

    var mouthDown:Float = 0
    var mouthUp:Float = 0
    var mouthL:Float = 0
    var mouthR:Float = 0
    
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
        for x in 0...11{
            let buttonXposition=800
            //位置を変えながらボタンを作る
            let btn : UIButton = callibrationButton(
                x:x,
                frame:CGRect(x: CGFloat(buttonXposition),y: CGFloat(x)*90,width: 80,height: 50))
            if(x<6){
                btn.frame=CGRect(x: CGFloat(buttonXposition),y: CGFloat(x)*90+200,width: 160,height: 50)
            }else{
                btn.frame=CGRect(x: CGFloat(buttonXposition+180),y: CGFloat(x-6)*90+200,width: 160,height: 50)
            }
            // sampleというキーを指定して保存していたString型の値を取り出す
            if let value = userDefaults.string(forKey: callibrationArr[x]) {
                btn.setTitle(callibrationArr[x]+":"+value, for: .normal)
            }else{
                btn.setTitle(callibrationArr[x], for: .normal)
            }
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
        print(mybtn.x)
        print(callibrationPosition[mybtn.x])
        if(callibrationArr[mybtn.x]=="普通"){
            print("普通")
            for x in 0...11{
                userDefaults.set(callibrationPosition[x], forKey: "普通"+callibrationArr[x])
            }
//            userDefaults.set(callibrationPosition[0], forKey: "普通"+callibrationArr[0])
//            userDefaults.set(callibrationPosition[1], forKey: "普通"+callibrationArr[1])
        }else{
            userDefaults.set(callibrationPosition[mybtn.x], forKey: callibrationArr[mybtn.x])
        }
        // UserDefaultsへの値の保存を明示的に行う
        userDefaults.synchronize()
        mybtn.setTitle(String(callibrationPosition[mybtn.x]), for: .normal)
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
//        let callibrationArr:[String]=["口左","口右","口上","口下","頰右","頰左","眉上","眉下","右笑","左笑","普通","a","b"]
//        let callibrationPosition:[Float]=[0,0,0,0,0,0,0,0,0,0,0,0,0]
        //print(faceAnchor.geometry.vertices[24][1],"24")
        //print(faceAnchor.geometry.vertices[25][1],"25")
        //口の右側の座標:638,口の左側の座標:405
        callibrationPosition[0] = faceAnchor.geometry.vertices[638][0]
        callibrationPosition[1] = faceAnchor.geometry.vertices[405][0]
        //口24を見る。口を上にしたときのy座標と口を下にしたときのy座標:
        callibrationPosition[2] = faceAnchor.geometry.vertices[24][1]
        callibrationPosition[3] = faceAnchor.geometry.vertices[24][1]
        //口右:638,口左:329のz座標を保存
        callibrationPosition[4] = faceAnchor.geometry.vertices[638][2]
        callibrationPosition[5] = faceAnchor.geometry.vertices[405][2]
        //眉上:762,眉下のy座標
        callibrationPosition[6] = faceAnchor.geometry.vertices[762][1]
        callibrationPosition[7] = faceAnchor.geometry.vertices[762][1]
        
        print(callibrationPosition[0])
        mouthR = faceAnchor.geometry.vertices[25][1]
            // 認識していたら青色に
        DispatchQueue.main.async {
            //print(self.tableView.contentOffset.y)
            self.tracking.backgroundColor = UIColor.blue
            // sampleというキーを指定して保存していたString型の値を取り出す
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
