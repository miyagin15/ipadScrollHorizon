//
//  ViewController.swift
//  test2
//
//  Created by ginga-miyata on 2019/08/02.
//  Copyright © 2019 ginga-miyata. All rights reserved.
//

import ARKit
import AudioToolbox
import Foundation
import Network
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var myCollectionView: UICollectionView!

    var changeNum = 0
    var callibrationUseBool = false

    var inputMethodString = "velocity"

    // 顔を認識できている描画するView
    @IBOutlet var tracking: UIView!

    @IBOutlet var inputClutchView: UIView!

    @IBOutlet var goalLabel: UILabel!
    @IBAction func timeCount(_: Any) {}

    @IBOutlet var timeCount: UISlider!
    @IBOutlet var functionalExpression: UISlider!

    @IBOutlet var sceneView: ARSCNView!
    // スクロール量を調整するSlider
    var ratioChange: Float = 5.0
    @IBAction func ratioChanger(_ sender: UISlider) {
        ratioChange = sender.value * 10
    }

    @IBOutlet var buttonLabel: UIButton!
    @IBAction func changeUseFace(_: Any) {
        changeNum = changeNum + 1
        i = 0
        time = 0
        goalLabel.text = String(goalPositionInt[i])
    }
    // 下を向いている度合いを示す
    @IBOutlet var orietationLabel: UILabel!
    @IBAction func toConfig(_: Any) {
        let secondViewController = storyboard?.instantiateViewController(withIdentifier: "CalibrationViewController") as! CalibrationViewController
        secondViewController.modalPresentationStyle = .fullScreen
        present(secondViewController, animated: true, completion: nil)
    }

    @IBAction func sendFile(_: Any) {
        // createFile(fileArrData: tapData)
        createCSV(fileArrData: nowgoal_Data)
    }

    @IBOutlet var functionalExpressionLabel: UILabel!
    @IBOutlet var callibrationBoolLabel: UIButton!
    @IBAction func callibrationConfigChange(_: Any) {
        if callibrationUseBool == false {
            callibrationUseBool = true
            callibrationBoolLabel.setTitle("キャリブレーション使う", for: .normal)
            return
        } else {
            callibrationUseBool = false
            callibrationBoolLabel.setTitle("キャリブレーション使わない", for: .normal)
            return
        }
    }

    @IBOutlet var inputMethodLabel: UIButton!
    @IBAction func inputMethodChange(_: Any) {
        if inputMethodString == "velocity" {
            inputMethodString = "position"
            inputMethodLabel.setTitle("position", for: .normal)
            return
//        } else if inputMethodString == "position" {
//            inputMethodString = "p_mouse"
//            inputMethodLabel.setTitle("p_mouse", for: .normal)
//            return
        } else if inputMethodString == "position" {
            inputMethodString = "velocity"
            inputMethodLabel.setTitle("velocity", for: .normal)
            return
        }
    }

    // 値を端末に保存するために宣言
    let userDefaults = UserDefaults.standard
    private let cellIdentifier = "cell"
    // Trackingfaceを使うための設定
    private let defaultConfiguration: ARFaceTrackingConfiguration = {
        let configuration = ARFaceTrackingConfiguration()
        return configuration
    }()

    // var NetWork = NetWorkViewController()
    // ゴールの目標セルを決める
    var goalPositionInt: [Int] = [10, 15, 25, 50, 51, 50, 25, 15, 10]
    // ゴールの目標位置を決める
    var goalPosition: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    private var tapData: [[Float]] = [[]]
    private var nowgoal_Data: [Float] = []
    let callibrationArr: [String] = ["口左", "口右", "口上", "口下", "頰右", "頰左", "眉上", "眉下", "右笑", "左笑", "上唇", "下唇", "普通"]
    // 初期設定のためのMAXの座標を配列を保存する
    var callibrationPosition: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    // 初期設定のMINの普通の状態を保存する
    var callibrationOrdinalPosition: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var documentInteraction: UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()
        createScrollVIew()
        decideGoalpositionTimeCount()
        createGoalView()
        initialCallibrationSettings()

        sceneView.delegate = self
        //timeInterval秒に一回update関数を動かす
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }

    @objc func update() {
        DispatchQueue.main.async {
            self.tracking.backgroundColor = UIColor.white
        }
    }

    // Cellの総数を返す
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 100
    }

    // Cellに値を設定する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        return cell
    }

    private func initialCallibrationSettings() {
        for x in 0 ... 11 {
            if let value = userDefaults.string(forKey: callibrationArr[x]) {
                callibrationPosition[x] = Float(value)!
            } else {
                print("no value", x)
            }
        }
        print("口右:638", userDefaults.string(forKey: callibrationArr[0])!)
        // 0:口左、1:口右
//        callibrationOrdinalPosition[0]=userDefaults.float(forKey: "普通"+callibrationArr[0])
//        callibrationOrdinalPosition[1]=userDefaults.float(forKey: "普通"+callibrationArr[1])
        for x in 0 ... 11 {
            callibrationOrdinalPosition[x] = userDefaults.float(forKey: "普通" + callibrationArr[x])
        }
    }

    // scrolViewを作成する
    private func createScrollVIew() {
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        // Cell一つ一つの大きさ.
        layout.itemSize = CGSize(width: 100, height: 600)
        layout.minimumLineSpacing = 0.1
        // Cellのマージン.
        // layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.scrollDirection = .horizontal

        // layout.scrollDirection = .vertical

        // セクション毎のヘッダーサイズ.
        // layout.headerReferenceSize = CGSize(width:10,height:30)
        // CollectionViewを生成.
        // myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 150, width: 600, height: 600),
                                            collectionViewLayout: layout)
        myCollectionView.backgroundColor = UIColor.white
        // Cellに使われるクラスを登録.
        myCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.contentSize = CGSize(width: 1800, height: 600)
        view.addSubview(myCollectionView)
    }

    private func decideGoalpositionTimeCount() {
        goalLabel.text = String(goalPositionInt[0])
        for i in 0 ..< goalPositionInt.count {
            goalPosition[i] = Float(goalPositionInt[i] * 100 - 200)
        }
        timeCount.maximumValue = 50
        timeCount.minimumValue = 0
        timeCount.value = 0
    }

    private func createGoalView() {
        let goalView = UIView()
        view.addSubview(goalView)
        goalView.frame = CGRect(x: 200, y: 150, width: 150, height: 700)
        goalView.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0.8, alpha: 0.5)
        view.addSubview(goalView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(defaultConfiguration)
        // NetWork.startConnection(to: "a")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
        // NetWork.stopConnection()
    }

    var lastValueR: CGFloat = 0
    // LPFの比率
    var LPFRatio: CGFloat = 0.9
    // right scroll
    private func rightScrollMainThread(ratio: CGFloat) {
        DispatchQueue.main.async {
            if self.myCollectionView.contentOffset.x > 6000 {
                return
            }
            self.functionalExpression.value = Float(ratio)
            self.functionalExpressionLabel.text = String(Float(ratio))
            if self.inputMethodString == "velocity" {
                let ratio = self.scrollRatioChange(ratio)
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x + 10 * ratio * CGFloat(self.ratioChange), y: 0)
//            } else if self.inputMethodString == "position" {
//                self.myCollectionView.contentOffset = CGPoint(x: 300 * ratio * CGFloat(self.ratioChange), y: 0)
            } else {
                let ClutchPosition = self.userDefaults.float(forKey: "nowCollectionViewPosition")
                let outPutLPF = self.LPFRatio * self.lastValueR + (1 - self.LPFRatio) * ratio
                self.lastValueR = outPutLPF
                self.myCollectionView.contentOffset = CGPoint(x: CGFloat(ClutchPosition) + 100 * outPutLPF * CGFloat(self.ratioChange), y: 0)
            }
            // self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
        }
    }

    var lastValueL: CGFloat = 0
    // left scroll
    private func leftScrollMainThread(ratio: CGFloat) {
        DispatchQueue.main.async {
            if self.myCollectionView.contentOffset.x < 0 {
                return
            }
            self.functionalExpression.value = -Float(ratio)
            self.functionalExpressionLabel.text = String(Float(-ratio))
            if self.inputMethodString == "velocity" {
                let ratio = self.scrollRatioChange(ratio)
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x - 10 * ratio * CGFloat(self.ratioChange), y: 0)
//            } else if self.inputMethodString == "position" {
//                self.myCollectionView.contentOffset = CGPoint(x: -300 * ratio * CGFloat(self.ratioChange), y: 0)
            } else {
                let ClutchPosition = self.userDefaults.float(forKey: "nowCollectionViewPosition")
                let outPutLPF = self.LPFRatio * self.lastValueL + (1 - self.LPFRatio) * ratio
                self.lastValueL = outPutLPF
                self.myCollectionView.contentOffset = CGPoint(x: CGFloat(ClutchPosition) - 100 * outPutLPF * CGFloat(self.ratioChange), y: 0)
            }
        }
    }

    private func scrollRatioChange(_ ratioValue: CGFloat) -> CGFloat {
        var changeRatio: CGFloat = 0
        // y = 1.5x^2
        // changeRatio = 1.5 * ratioValue * ratioValue

//        if ratioValue < 0.25 {
//            changeRatio = ratioValue * 0.2
//        } else if ratioValue > 0.55 {
//            changeRatio = (ratioValue - 0.55) * 1.5 + 0.35
//        } else {
//            changeRatio = ratioValue - 0.25 + 0.05
//        }
        changeRatio = tanh((ratioValue * 3 - 1.5 - 0.8) * 3.14 / 2) * 0.7 + 0.7
        // changeRatio = ratioValue

//        if ratioValue < 0.55 {
//            changeRatio = 0.10
//        } else if ratioValue > 0.55 {
//            changeRatio = 1
//        }

        print(changeRatio, "changeRatio")
//        if ratioValue < 0.25 {
//            changeRatio = ratioValue * 0.2
//        } else if ratioValue > 0.55 {
//            changeRatio = ratioValue * 1.5
//        } else {
//            changeRatio = ratioValue
//        }
        return changeRatio
    }

    // MARK: - ARSCNViewDelegate

    func session(_: ARSession, didFailWithError _: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    var i: Int = 0
    var time: Int = 0
    //tarcking状態
    var tableViewPosition: CGFloat = 0
    var myCollectionViewPosition: CGFloat = 0
    var before_cheek_right: Float = 0
    var after_cheek_right: Float = 0
    var before_cheek_left: Float = 0
    var after_cheek_left: Float = 0
    let sound: SystemSoundID = 1013

    func renderer(_: SCNSceneRenderer, didUpdate _: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        //  認識していたら青色に
        DispatchQueue.main.async {
            // print(self.tableView.contentOffset.y)
            self.inputClutchView.backgroundColor = UIColor.red
            self.tracking.backgroundColor = UIColor.blue
        }
        // 顔のxyz位置
        // print(faceAnchor.transform.columns.3.x, faceAnchor.transform.columns.3.y, faceAnchor.transform.columns.3.z)
        // 下を向いている時の処理
        let ratioLookDown = faceAnchor.transform.columns.1.z
        DispatchQueue.main.async {
            self.orietationLabel.text = String(ratioLookDown)
        }
        if ratioLookDown > 0.65 {
            //  認識していたら青色に
            DispatchQueue.main.async {
                self.userDefaults.set(self.myCollectionView.contentOffset.x, forKey: "nowCollectionViewPosition")
                // print(self.tableView.contentOffset.y)
                self.inputClutchView.backgroundColor = UIColor.white
            }
            print("うなづき")
            return
        }
        let goal = goalPosition[self.i]
        DispatchQueue.main.async {
            self.myCollectionViewPosition = self.myCollectionView.contentOffset.x
            // 目標との距離が近くなったら
            if goal - 50 < Float(self.myCollectionViewPosition), Float(self.myCollectionViewPosition) < goal {
                print("クリア")
                self.time = self.time + 1
                self.timeCount.value = Float(self.time)
                if self.time > 50 {
                    print("クリア2")
                    AudioServicesPlaySystemSound(self.sound)
                    if self.i < self.goalPositionInt.count - 1 {
                        self.i = self.i + 1
                        self.timeCount.value = 0
                        self.buttonLabel.backgroundColor = UIColor.blue
                        if self.i == self.goalPosition.count - 1 {
                            self.goalLabel.text = "次:" + String(self.goalPositionInt[self.i])
                        } else {
                            self.goalLabel.text = "次:" + String(self.goalPositionInt[self.i]) + "---次の次:" + String(self.goalPositionInt[self.i + 1])
                        }
                    } else {
                        self.myCollectionView.contentOffset.x = 0
                        self.goalLabel.text = "終了"
                        // データをパソコンに送る(今の場所と目標地点)
                        DispatchQueue.main.async {
                            // self.NetWork.send(message: [0,0])
                        }
                    }
                }
            } else {
                self.time = 0
            }
        }
        // CSVを作るデータに足していく
        DispatchQueue.main.async {
            if Float(self.myCollectionViewPosition) > 5 {
                // self.tapData.append([(Float(self.tableViewPosition)),(self.goalPosition[self.i])])
                self.nowgoal_Data.append(Float(self.myCollectionViewPosition))
                self.nowgoal_Data.append(Float(self.goalPosition[self.i]))
            }
            if Float(self.myCollectionViewPosition) < -160 {
                self.goalLabel.text = "5.0"
                self.nowgoal_Data = []
                // self.tapData = []
            }
            // print(Float(self.tableViewPosition))
            // データをパソコンに送る(今の場所と目標地点)
            // self.NetWork.send(message: [Float(self.tableViewPosition),self.goalPosition[self.i]])
        }

        let changeAction = changeNum % 7

        switch changeAction {
        case 0:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("MouthRL", for: .normal)
            }
            let mouthLeftBS = faceAnchor.blendShapes[.mouthLeft] as! Float
            let mouthRightBS = faceAnchor.blendShapes[.mouthRight] as! Float
            var mouthLeft: Float = 0
            var mouthRight: Float = 0
            if callibrationUseBool == true {
                let mouthLeft = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[638][0], maxFaceAUVertex: callibrationPosition[0], minFaceAUVertex: callibrationOrdinalPosition[0])
                // print("mouthLeft", mouthLeft)
                let mouthRight = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[405][0], maxFaceAUVertex: callibrationPosition[1], minFaceAUVertex: callibrationOrdinalPosition[1])
                // print("mouthRight", mouthRight)

                if mouthLeft < 0.1, mouthRight < 0.1 {
                    return
                }
                // print(mouthLeftBS, mouthRightBS)
                // mouthRightが逆を表す
                if mouthLeft > mouthRight, mouthRightBS > 0.02 {
                    leftScrollMainThread(ratio: CGFloat(mouthLeft))

                } else if mouthRight > mouthLeft, mouthLeftBS > 0.02 {
                    rightScrollMainThread(ratio: CGFloat(mouthRight))
                }
            } else {
//                if let mouthLeft = faceAnchor.blendShapes[.mouthLeft] as? Float {
//                    if mouthLeft > 0.02 {
//                        // self.scrollDownInMainThread(ratio: CGFloat(mouthLeft))
//                        rightScrollMainThread(ratio: CGFloat(mouthLeft))
//                    }
//                }
//                if let mouthRight = faceAnchor.blendShapes[.mouthRight] as? Float {
//                    if mouthRight > 0.02 {
//                        // self.scrollUpInMainThread(ratio: CGFloat(mouthRight))
//                        leftScrollMainThread(ratio: CGFloat(mouthRight))
//                    }
//                }
                mouthLeft = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[638][0], maxFaceAUVertex: 0.008952, minFaceAUVertex: 0.021727568)
                // print("mouthLeft", mouthLeft)
                mouthRight = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[405][0], maxFaceAUVertex: -0.004787985, minFaceAUVertex: -0.0196867)
                // print("mouthRight", mouthRight)
                if mouthLeft < 0.1, mouthRight < 0.1 {
                    return
                }
                // print(mouthLeftBS, mouthRightBS)
                if mouthLeft > mouthRight, mouthRightBS > 0.02 {
                    leftScrollMainThread(ratio: CGFloat(mouthLeft))

                } else if mouthRight > mouthLeft, mouthLeftBS > 0.02 {
                    rightScrollMainThread(ratio: CGFloat(mouthRight))
                }
            }

        case 1:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("Hands", for: .normal)
            }

            // 頰を動かす。口角のz座標
//            before_cheek_right = after_cheek_right
//            before_cheek_left = after_cheek_left
//            after_cheek_right = faceAnchor.geometry.vertices[636][2]+faceAnchor.geometry.vertices[678][2]+faceAnchor.geometry.vertices[635][2]
//
//
//            after_cheek_left = faceAnchor.geometry.vertices[405][2]+faceAnchor.geometry.vertices[243][2]+faceAnchor.geometry.vertices[245][2]
//            print(after_cheek_right)
//            print(after_cheek_left)

            /*
             print((after_cheek_right-before_cheek_right)/before_cheek_right)
             print(after_cheek_right)
             print(before_cheek_right)
             */
            // print(abs((after_cheek_right-before_cheek_right) / before_cheek_right ))

//            if abs((after_cheek_right-before_cheek_right) / before_cheek_right )>0.003{
//                print("右の頬move")
//                self.scrollDownInMainThread(ratio: CGFloat(0.8))
//            }
//
//            if abs(after_cheek_left)>0.052{
//                print("左の頬move")
//                self.scrollDownInMainThread(ratio: CGFloat(0.8))
//            }

            // 動かす部分
//            if abs(after_cheek_right)>0.152{
//                print("右の頬move")
//                self.scrollDownInMainThread(ratio: CGFloat(0.8))
//            }
//            if abs(after_cheek_left)>0.152{
//                print("左の頬move")
//                self.scrollUpInMainThread(ratio: CGFloat(0.8))
//            }
//

//            if let cheek_right = faceAnchor.geometry.vertices[187] as? simd_float3{
//                print(cheek_right)
//            }
//            if let cheek_leght = faceAnchor.geometry.vertices[676] as? simd_float3{
//                print(cheek_leght)
//            }
        //        case (1):
        //            buttonLabel.setTitle("Eye", for: .normal)
        //            if let mouthLeft = faceAnchor.blendShapes[.eyeLookDownLeft] as? Float {
        //                if mouthLeft < 0.2 {
        //                    self.scrollDownInMainThread(ratio: CGFloat(1/(mouthLeft+0.1)/20))
        //                }
        //            }
        case 2:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("Brow", for: .normal)
            }
            var browInnerUp: Float = 0
            var browDownLeft: Float = 0
            if callibrationUseBool == true {
                browInnerUp = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: callibrationPosition[6], minFaceAUVertex: callibrationOrdinalPosition[6])
                print("browInnerUp", browInnerUp)
                browDownLeft = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: callibrationPosition[7], minFaceAUVertex: callibrationOrdinalPosition[7])
                print("browDownLeft", browDownLeft)

                if browInnerUp < 0.1, browDownLeft < 0.1 {
                    return
                }
                if browInnerUp > browDownLeft {
                    leftScrollMainThread(ratio: CGFloat(browInnerUp))
                } else {
                    rightScrollMainThread(ratio: CGFloat(browDownLeft))
                }
            } else {
                browInnerUp = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][1], maxFaceAUVertex: 0.008952, minFaceAUVertex: 0.021727568)
                // print("mouthLeft", mouthLeft)
                browDownLeft = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[762][0], maxFaceAUVertex: -0.004787985, minFaceAUVertex: -0.0196867)
                // print("mouthRight", mouthRight)
                if browInnerUp < 0.1, browDownLeft < 0.1 {
                    return
                }
                // print(mouthLeftBS, mouthRightBS)
                if browInnerUp > browDownLeft {
                    leftScrollMainThread(ratio: CGFloat(browInnerUp))

                } else if browDownLeft > browInnerUp {
                    rightScrollMainThread(ratio: CGFloat(browDownLeft))
                }
//                if let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as? Float {
//                    if browInnerUp > 0.5 {
//                        leftScrollMainThread(ratio: CGFloat(browInnerUp - 0.4) * 1.5)
//                    }
//                }
//
//                if let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? Float {
//                    if browDownLeft > 0.2 {
//                        rightScrollMainThread(ratio: CGFloat(browDownLeft))
//                    }
//                }
            }
        case 3:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("mouthCentral", for: .normal)
            }
            // let callibrationArr:[String]=["口左","口右","口上","口下","頰右","頰左","眉上","眉下","右笑","左笑","普通","a","b"]
            var mouthUp: Float = 0
            var mouthDown: Float = 0
            if callibrationUseBool == true {
                mouthUp = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: callibrationPosition[2], minFaceAUVertex: callibrationOrdinalPosition[2])
                print("mouthUp", mouthUp)
                mouthDown = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: callibrationPosition[3], minFaceAUVertex: callibrationOrdinalPosition[3])
                print("mouthDown", mouthDown)

                if mouthUp < 0.1, mouthDown < 0.1 {
                    return
                }
                if mouthUp > mouthDown {
                    leftScrollMainThread(ratio: CGFloat(mouthUp))
                } else {
                    rightScrollMainThread(ratio: CGFloat(mouthDown))
                }
            } else {
                mouthUp = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: -0.03719348, minFaceAUVertex: -0.04107782)
                print("mouthUp", mouthUp)
                mouthDown = faceAURangeChange(faceAUVertex: faceAnchor.geometry.vertices[24][1], maxFaceAUVertex: -0.04889179, minFaceAUVertex: -0.04107782)
                print("mouthDown", mouthDown)

                if mouthUp < 0.1, mouthDown < 0.1 {
                    return
                }
                if mouthUp > mouthDown {
                    leftScrollMainThread(ratio: CGFloat(mouthUp))
                } else {
                    rightScrollMainThread(ratio: CGFloat(mouthDown))
                }
            }
        case 4:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("cheekPuff", for: .normal)
            }
            let cheekR = faceAURangeChange(faceAUVertex: (faceAnchor.geometry.vertices[697][2] + faceAnchor.geometry.vertices[826][2] + faceAnchor.geometry.vertices[839][2]) / 3, maxFaceAUVertex: callibrationPosition[4], minFaceAUVertex: callibrationOrdinalPosition[4])
            print("cheekR", cheekR)
            let cheekL = faceAURangeChange(faceAUVertex: (faceAnchor.geometry.vertices[245][2] + faceAnchor.geometry.vertices[397][2] + faceAnchor.geometry.vertices[172][2]) / 3, maxFaceAUVertex: callibrationPosition[5], minFaceAUVertex: callibrationOrdinalPosition[5])
            print("cheekL", cheekL)

            if cheekR < 0.1, cheekL < 0.1 {
                return
            }
            if cheekL > cheekR {
                leftScrollMainThread(ratio: CGFloat(cheekL))
            } else {
                rightScrollMainThread(ratio: CGFloat(cheekR))
            }
        case 5:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("ripRoll", for: .normal)
            }
            let mouthRollUpper = faceAnchor.blendShapes[.mouthRollUpper] as! Float
            let mouthRollLower = faceAnchor.blendShapes[.mouthRollLower] as! Float
            if callibrationUseBool == true {
                let mouthRollUp = faceAURangeChange(faceAUVertex: mouthRollUpper, maxFaceAUVertex: callibrationPosition[10], minFaceAUVertex: callibrationOrdinalPosition[10])
                print("mouthRollUp", mouthRollUp)
                let mouthRollDown = faceAURangeChange(faceAUVertex: mouthRollLower, maxFaceAUVertex: callibrationPosition[11], minFaceAUVertex: callibrationOrdinalPosition[11])
                print("mouthRollDown", mouthRollDown)

                if mouthRollUp < 0.1, mouthRollDown < 0.1 {
                    return
                }
                if mouthRollDown > mouthRollUp {
                    leftScrollMainThread(ratio: CGFloat(mouthRollDown))
                } else {
                    rightScrollMainThread(ratio: CGFloat(mouthRollUp))
                }
            } else {
                if mouthRollUpper < 0.1, mouthRollLower < 0.1 {
                    return
                }
                if mouthRollUpper > mouthRollLower {
                    rightScrollMainThread(ratio: CGFloat(mouthRollUpper))
                } else {
                    leftScrollMainThread(ratio: CGFloat(mouthRollLower))
                }
            }
        default:
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("CheekSquint_halfsmile", for: .normal)
            }
            let cheekSquintLeft = faceAnchor.blendShapes[.mouthSmileLeft] as! Float
            let cheekSquintRight = faceAnchor.blendShapes[.mouthSmileRight] as! Float
            if callibrationUseBool == true {
                let cheekR = faceAURangeChange(faceAUVertex: cheekSquintLeft, maxFaceAUVertex: callibrationPosition[8], minFaceAUVertex: callibrationOrdinalPosition[8])
                print("cheekR", cheekR)
                let cheekL = faceAURangeChange(faceAUVertex: cheekSquintRight, maxFaceAUVertex: callibrationPosition[9], minFaceAUVertex: callibrationOrdinalPosition[9])
                print("cheekL", cheekL)

                if cheekR < 0.1, cheekL < 0.1 {
                    return
                }
                if cheekL > cheekR {
                    leftScrollMainThread(ratio: CGFloat(cheekL))
                } else {
                    rightScrollMainThread(ratio: CGFloat(cheekR))
                }
            } else {
                if cheekSquintLeft < 0.1, cheekSquintRight < 0.1 {
                    return
                }
                if cheekSquintLeft > cheekSquintRight {
                    rightScrollMainThread(ratio: CGFloat(cheekSquintLeft))
                } else {
                    leftScrollMainThread(ratio: CGFloat(cheekSquintRight))
                }
            }

//        default:
//            buttonLabel.setTitle("Rip", for: .normal)
//            if let mouthLeft = faceAnchor.blendShapes[.cheekSquintLeft] as? Float {
//                if mouthLeft > 0.1 {
//                    self.scrollDownInMainThread(ratio: CGFloat(mouthLeft))
//                }
//            }
//
//            if let mouthRight = faceAnchor.blendShapes[.cheekSquintRight] as? Float {
//                if mouthRight > 0.1 {
//                    self.scrollUpInMainThread(ratio: CGFloat(mouthRight))
//                }
//            }
        }
    }

    // y = x/(max-min)+min/(min-max)
    private func faceAURangeChange(faceAUVertex: Float, maxFaceAUVertex: Float, minFaceAUVertex: Float) -> Float {
        let faceAUChangeValue = faceAUVertex / (maxFaceAUVertex - minFaceAUVertex) + minFaceAUVertex / (minFaceAUVertex - maxFaceAUVertex)
        return faceAUChangeValue
    }

    func createCSV(fileArrData: [Float]) {
        var fileStrData: String = ""
        let fileName = buttonLabel.titleLabel!.text! + "_" + inputMethodString + ".csv"

        // StringのCSV用データを準備
        // print(fileArrData)
        if fileArrData.count == 0 {
            goalLabel.text = "データがありません。"
            return
        }
        // キャリブレーション座標のラベル追加
        for x in 0 ... 11 {
            if x != 11 {
                fileStrData += String(callibrationArr[x]) + ","
            } else {
                fileStrData += String(callibrationArr[x]) + "\n"
            }
        }
        // キャリブレーションMAX座標の値
        for x in 0 ... 11 {
            if x != 11 {
                if let value = userDefaults.string(forKey: callibrationArr[x]) {
                    fileStrData += String(value) + ","
                } else {
                    print("no value", x)
                }
            } else {
                if let value = userDefaults.string(forKey: callibrationArr[x]) {
                    fileStrData += String(value) + "\n"
                } else {
                    print("no value", x)
                }
            }
        }
        // 普通の時のラベル
        for x in 0 ... 11 {
            if x != 11 {
                fileStrData += String("普通" + callibrationArr[x]) + ","
            } else {
                fileStrData += String("普通" + callibrationArr[x]) + "\n"
            }
        }
        // 普通の時の座標
        for x in 0 ... 11 {
            callibrationOrdinalPosition[x] = userDefaults.float(forKey: "普通" + callibrationArr[x])
            if x != 11 {
                fileStrData += String(callibrationOrdinalPosition[x]) + ","
            } else {
                fileStrData += String(callibrationOrdinalPosition[x]) + "\n"
            }
        }

        fileStrData += "position,goalPosition\n"
        for i in 1 ... fileArrData.count {
            if i % 2 != 0 {
                fileStrData += String(fileArrData[i - 1]) + ","
            }
            if i % 2 == 0 {
                fileStrData += String(fileArrData[i - 1]) + "\n"
            }
        }
        // print(fileStrData)

        // DocumentディレクトリのfileURLを取得
        let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!

        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let FilePath = documentDirectoryFileURL.appendingPathComponent(fileName)

        print("書き込むファイルのパス: \(FilePath)")

        do {
            try fileStrData.write(to: FilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("failed to write: \(error)")
        }

        documentInteraction = UIDocumentInteractionController(url: FilePath)
        documentInteraction.presentOpenInMenu(from: CGRect(x: 10, y: 10, width: 100, height: 50), in: view, animated: true)
        nowgoal_Data = []
    }
}
