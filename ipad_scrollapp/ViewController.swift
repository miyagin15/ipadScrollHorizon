//
//  ViewController.swift
//  test2
//
//  Created by ginga-miyata on 2019/08/02.
//  Copyright © 2019 ginga-miyata. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Network


class ViewController: UIViewController, ARSCNViewDelegate, UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource{
    
    var myCollectionView : UICollectionView!

    var changeNum = 0
    //顔を認識できている描画するView
    @IBOutlet weak var tracking: UIView!
    @IBOutlet var goalLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBAction func timeCount(_ sender: Any) {
    }
    @IBOutlet var timeCount: UISlider!
    @IBOutlet var functionalExpression: UISlider!
    
    @IBOutlet var sceneView: ARSCNView!
    //スクロール量を調整するSlider
    var  ratioChange :Float=5.0
    @IBAction func ratioChanger(_ sender: UISlider) {
        ratioChange=sender.value * 10
    }
    @IBOutlet var buttonLabel: UIButton!
    @IBAction func changeUseFace(_ sender: Any) {
        changeNum = changeNum + 1
        i = 0
        time = 0
        self.goalLabel.text = String(goalPositionInt[i])
    }
    @IBAction func toConfig(_ sender: Any) {
    }
    @IBAction func sendFile(_ sender: Any) {
        //createFile(fileArrData: tapData)
        createCSV(fileArrData: nowgoal_Data)
    }
    @IBOutlet var functionalExpressionLabel: UILabel!
    //ウインクした場所を特定するために定義
    let userDefaults = UserDefaults.standard
    private let cellIdentifier = "cell"
    //Trackingfaceを使うための設定
    private let defaultConfiguration: ARFaceTrackingConfiguration = {
        let configuration = ARFaceTrackingConfiguration()
        return configuration
    }()
    
    //var NetWork = NetWorkViewController()
    //ゴールの目標セルを決める
    var goalPositionInt:[Int] = [10,11,50,11,10]
    //ゴールの目標位置を決める
    var goalPosition:[Float] = [0,0,0,0,0]
    private var tapData: [[Float]] = [[]]
    private var nowgoal_Data: [Float]=[]
    
    var documentInteraction: UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()
        createScrollVIew()
        decideGoalpositionTimeCount()
        createGoalView()
        createTableView()
        //timeInterval秒に一回update関数を動かす
        _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        DispatchQueue.main.async {
            self.tracking.backgroundColor = UIColor.white
        }
    }
    /*
     Cellの総数を返す
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 70
    }
    /*
     Cellに値を設定する
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell : CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath) as! CollectionViewCell
        cell.textLabel?.text = indexPath.row.description
        return cell
    }
    
    //scrolViewを作成する
    private func createScrollVIew(){
        // CollectionViewのレイアウトを生成.
        let layout = UICollectionViewFlowLayout()
        // Cell一つ一つの大きさ.
        layout.itemSize = CGSize(width:100, height:600)
        layout.minimumLineSpacing = 0.1
        // Cellのマージン.
        //layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.scrollDirection = .horizontal
        
        //layout.scrollDirection = .vertical
        
        // セクション毎のヘッダーサイズ.
        //layout.headerReferenceSize = CGSize(width:10,height:30)
        // CollectionViewを生成.
        //myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView = UICollectionView(frame:CGRect(x:0,y:150,width: 600,height: 600),
            collectionViewLayout: layout)
        myCollectionView.backgroundColor=UIColor.white
        // Cellに使われるクラスを登録.
        myCollectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.contentSize=CGSize(width: 1800, height: 600)
        self.view.addSubview(myCollectionView)
    }
    
    private func decideGoalpositionTimeCount(){
        self.goalLabel.text = String(goalPositionInt[0])
        for i in 0..<goalPositionInt.count{
            goalPosition[i] = Float(goalPositionInt[i] * 100-200)
        }
        timeCount.maximumValue = 50
        timeCount.minimumValue = 0
        timeCount.value=0
    }
    private func createGoalView(){
        let goalView = UIView()
        self.view.addSubview(goalView)
        goalView.frame = CGRect(x:200,y:150, width:150 ,height: 700)
        goalView.backgroundColor = UIColor(red: 0, green: 0.3, blue: 0.8, alpha: 0.5)
        self.view.addSubview(goalView)
    }
    private func createTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        sceneView.delegate = self
        //スクロールできる範囲を指定する
        tableView.contentSize = CGSize(width: 340, height: 2000)
        tableView.rowHeight = 800
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(red: 255/255, green: 1, blue: CGFloat(11 - indexPath.row)/10, alpha: 0.25)
        
        cell.textLabel?.text = "セル " + indexPath.row.description
        // 文字サイズ変更
        cell.textLabel?.font = UIFont.systemFont(ofSize: 80)
        return cell
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
    
    //up scroll
    private func scrollUpInMainThread(ratio :CGFloat) {
        DispatchQueue.main.async {
            if(self.tableView.contentOffset.y > 8000){
                return
            }
            self.functionalExpression.value = -Float(ratio)
            self.functionalExpressionLabel.text = String(-Float(ratio))
            if(ratio<0.25){
                let ratio = ratio * 0.3
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
            }
            else if(ratio>0.55){
                let ratio = ratio * 1.5
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
            }
            else{
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
            }
            //self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
        }
    }
    
    //down scroll
    private func scrollDownInMainThread(ratio :CGFloat) {
        print(ratio)
        DispatchQueue.main.async {
            if(self.tableView.contentOffset.y < 0){
                return
            }
            self.functionalExpression.value = Float(ratio)
            self.functionalExpressionLabel.text = String(Float(ratio))
            if(ratio<0.25){
                let ratio = ratio * 0.3
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - 10*ratio*CGFloat(self.ratioChange))
            }
            else if(ratio>0.55){
                let ratio = ratio * 1.5
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - 10*ratio*CGFloat(self.ratioChange))
            }
            else{
                self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - 10*ratio*CGFloat(self.ratioChange))
            }
            
            //self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y - 10*ratio*CGFloat(self.ratioChange))
        }
    }
    //right scroll
    private func rightScrollMainThread(ratio :CGFloat) {
        DispatchQueue.main.async {
            if(self.myCollectionView.contentOffset.x > 8000){
                return
            }
            self.functionalExpression.value = Float(ratio)
            self.functionalExpressionLabel.text = String(Float(ratio))
            if(ratio<0.25){
                let ratio = ratio * 0.3
                self.myCollectionView.contentOffset=CGPoint(x: self.myCollectionView.contentOffset.x+10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            else if(ratio>0.55){
                let ratio = ratio * 1.5
                self.myCollectionView.contentOffset=CGPoint(x: self.myCollectionView.contentOffset.x + 10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            else{
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x + 10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            //self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
        }
    }
    //left scroll
    private func leftScrollMainThread(ratio :CGFloat) {
        DispatchQueue.main.async {
            if(self.myCollectionView.contentOffset.x < 0){
                return
            }
            self.functionalExpression.value = -Float(ratio)
            self.functionalExpressionLabel.text = String(Float(-ratio))
            if(ratio<0.25){
                let ratio = ratio * 0.3
                self.myCollectionView.contentOffset=CGPoint(x: self.myCollectionView.contentOffset.x-10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            else if(ratio>0.55){
                let ratio = ratio * 1.5
                self.myCollectionView.contentOffset=CGPoint(x: self.myCollectionView.contentOffset.x - 10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            else{
                self.myCollectionView.contentOffset = CGPoint(x: self.myCollectionView.contentOffset.x - 10*ratio*CGFloat(self.ratioChange), y: 0)
            }
            //self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y + 10*ratio*CGFloat(self.ratioChange))
        }
    }

    // MARK: - ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    
    
    
    
    var i:Int = 0
    var time :Int = 0
    //tarcking状態
    var tableViewPosition :CGFloat = 0
    var myCollectionViewPosition :CGFloat = 0
    var before_cheek_right:Float = 0
    var after_cheek_right:Float = 0
    var before_cheek_left:Float = 0
    var after_cheek_left:Float = 0
    
    //let firstConfig:[Float] = userDefaults.array(forKey: "firstConfig") as! [Float]
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        let goal = self.goalPosition[self.i]
//        DispatchQueue.main.async {
//            self.tableViewPosition = self.tableView.contentOffset.y
//            //目標との距離が近くなったら
//            if( (Float(self.tableViewPosition) - goal) < 50 && (Float(self.tableViewPosition) - goal) > -50){
//                print("クリア")
//                self.time=self.time+1
//                self.timeCount.value=Float(self.time)
//                if(self.time>50){
//                    print("クリア2")
//                    if(self.i < self.goalPositionInt.count-1){
//                        self.i=self.i+1
//                        self.timeCount.value = 0
//                        self.buttonLabel.backgroundColor  = UIColor.blue
//                        self.goalLabel.text = "次:"+String(self.goalPositionInt[self.i]) + "---次の次:"+String(self.goalPositionInt[self.i+1])
//                    }else{
//                        self.tableView.contentOffset.y = 0
//                        self.goalLabel.text = "終了"
//                        //データをパソコンに送る(今の場所と目標地点)
//                        DispatchQueue.main.async {
//                            //self.NetWork.send(message: [0,0])
//                        }
//                    }
//                }
//            }else{
//                self.time=0
//            }
//        }
        DispatchQueue.main.async {
            self.myCollectionViewPosition = self.myCollectionView.contentOffset.x
            //目標との距離が近くなったら
            if goal-50<Float(self.myCollectionViewPosition) && Float(self.myCollectionViewPosition)<goal{
            //if((Float(self.myCollectionViewPosition)) - Float(100 * self.i) < -200.0 && (Float(self.myCollectionViewPosition)) - Float(100 * self.i) > -250.0){
            //if( (Float(self.myCollectionViewPosition) - goal) < 50 && (Float(self.myCollectionViewPosition) - goal) > -50){
                print("クリア")
                self.time=self.time+1
                self.timeCount.value=Float(self.time)
                if(self.time>50){
                    print("クリア2")
                    if(self.i < self.goalPositionInt.count-1){
                        self.i=self.i+1
                        self.timeCount.value = 0
                        self.buttonLabel.backgroundColor  = UIColor.blue
                        if self.i==self.goalPosition.count-1{
                            self.goalLabel.text = "次:"+String(self.goalPositionInt[self.i])
                        }else{
                            self.goalLabel.text = "次:"+String(self.goalPositionInt[self.i]) + "---次の次:"+String(self.goalPositionInt[self.i+1])
                        }
                    }else{
                        self.myCollectionView.contentOffset.x = 0
                        self.goalLabel.text = "終了"
                        //データをパソコンに送る(今の場所と目標地点)
                        DispatchQueue.main.async {
                            //self.NetWork.send(message: [0,0])
                        }
                    }
                }
            }else{
                self.time=0
            }
        }
        // 認識していたら青色に
        DispatchQueue.main.async {
            //print(self.tableView.contentOffset.y)
            self.tracking.backgroundColor = UIColor.blue
        }
        
        //CSVを作るデータに足していく縦スクロール
//        DispatchQueue.main.async {
//            if((Float(self.tableViewPosition) > 5)){
//                //self.tapData.append([(Float(self.tableViewPosition)),(self.goalPosition[self.i])])
//                self.nowgoal_Data.append(Float(self.tableViewPosition))
//                self.nowgoal_Data.append(Float(self.goalPosition[self.i]))
//            }
//            if(Float(self.tableViewPosition) < -160){
//                self.goalLabel.text = "5.0"
//                self.nowgoal_Data = []
//                //self.tapData = []
//
//            }
//            //print(Float(self.tableViewPosition))
//            //データをパソコンに送る(今の場所と目標地点)
//            //self.NetWork.send(message: [Float(self.tableViewPosition),self.goalPosition[self.i]])
//        }
        //CSVを作るデータに足していく
        DispatchQueue.main.async {
            if((Float(self.myCollectionViewPosition) > 5)){
                //self.tapData.append([(Float(self.tableViewPosition)),(self.goalPosition[self.i])])
                self.nowgoal_Data.append(Float(self.myCollectionViewPosition))
                self.nowgoal_Data.append(Float(self.goalPosition[self.i]))
            }
            if(Float(self.myCollectionViewPosition) < -160){
                self.goalLabel.text = "5.0"
                self.nowgoal_Data = []
                //self.tapData = []
                
            }
            //print(Float(self.tableViewPosition))
            //データをパソコンに送る(今の場所と目標地点)
            //self.NetWork.send(message: [Float(self.tableViewPosition),self.goalPosition[self.i]])
        }

        
        let changeAction = changeNum%5

        switch changeAction{
        case (0):
            DispatchQueue.main.async {
                self.buttonLabel.setTitle("MouthRL", for: .normal)
            }
            if let mouthLeft = faceAnchor.blendShapes[.mouthLeft] as? Float {
                if mouthLeft > 0.1 {
                    //self.scrollDownInMainThread(ratio: CGFloat(mouthLeft))
                    self.rightScrollMainThread(ratio: CGFloat(mouthLeft))
                }
            }
            
            if let mouthRight = faceAnchor.blendShapes[.mouthRight] as? Float {
                if mouthRight > 0.1 {
                    //self.scrollUpInMainThread(ratio: CGFloat(mouthRight))
                    self.leftScrollMainThread(ratio: CGFloat(mouthRight))
                }
            }
        case (1):
             DispatchQueue.main.async {
                self.buttonLabel.setTitle("Hands", for: .normal)
            }
            
            //頰を動かす。口角のz座標
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
            //print(abs((after_cheek_right-before_cheek_right) / before_cheek_right ))
            
//            if abs((after_cheek_right-before_cheek_right) / before_cheek_right )>0.003{
//                print("右の頬move")
//                self.scrollDownInMainThread(ratio: CGFloat(0.8))
//            }
//
//            if abs(after_cheek_left)>0.052{
//                print("左の頬move")
//                self.scrollDownInMainThread(ratio: CGFloat(0.8))
//            }
            
            //動かす部分
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
        case (2):
             DispatchQueue.main.async {
                self.buttonLabel.setTitle("Brow", for: .normal)
             }
            if let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as? Float {
                if browInnerUp > 0.5 {
                    self.scrollDownInMainThread(ratio: CGFloat(browInnerUp-0.4)*1.5)
                }
            }
        
            if let browDownLeft = faceAnchor.blendShapes[.browDownLeft] as? Float {
                if browDownLeft > 0.2 {
                    self.scrollUpInMainThread(ratio: CGFloat(browDownLeft))
                }
            }
        case (3):
             DispatchQueue.main.async {
                self.buttonLabel.setTitle("mouthCentral", for: .normal)
             }
            //口の中央
            print(faceAnchor.geometry.vertices[24][1],"24")
            print(faceAnchor.geometry.vertices[25][1],"25")
             
            let mouthCenter = (faceAnchor.geometry.vertices[24][1] + faceAnchor.geometry.vertices[25][1])/2
            
            if mouthCenter < -0.045{
                self.scrollUpInMainThread(ratio: CGFloat(0.8))
            }
            if mouthCenter > -0.039{
                self.scrollDownInMainThread(ratio: CGFloat(0.8))
            }

        default:
             DispatchQueue.main.async {
                self.buttonLabel.setTitle("Cheek", for: .normal)
             }
            if let cheekSquintLeft = faceAnchor.blendShapes[.cheekSquintLeft] as? Float {
                if cheekSquintLeft > 0.1 {
                    self.scrollDownInMainThread(ratio: CGFloat(cheekSquintLeft))
                }
            }

            if let cheekSquintRight = faceAnchor.blendShapes[.cheekSquintRight] as? Float {
                if cheekSquintRight > 0.1 {
                    self.scrollUpInMainThread(ratio: CGFloat(cheekSquintRight))
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
    func createFile(fileArrData : [[Float]]){
        
        var fileStrData:String = ""
        let fileName = buttonLabel.titleLabel!.text!+".csv"
        
        //StringのCSV用データを準備
        for singleArray in fileArrData{
            for singleString in singleArray{
                let singleString = String(singleString)
                fileStrData += "\"" + singleString + "\""
                if Float(singleString) != singleArray[singleArray.count-1]{
                    fileStrData += ","
                }
            }
            fileStrData += "\n"
        }
        print(fileStrData)
        
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
        
        documentInteraction = UIDocumentInteractionController()
        documentInteraction.url = FilePath
        
        if !(documentInteraction?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true))!
        {
            // 送信できるアプリが見つからなかった時の処理
            let alert = UIAlertController(title: "送信失敗", message: "ファイルを送れるアプリが見つかりません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        self.tapData=[[]]
        
    }
    
    func createCSV(fileArrData : [Float]) {
        
        var fileStrData:String = ""
        let fileName = buttonLabel.titleLabel!.text!+".csv"
        
        //StringのCSV用データを準備
        print(fileArrData)
        if fileArrData.count==0{
            self.goalLabel.text="データがありません。"
            return
        }
        for i in 1...fileArrData.count{
            if (i%2 != 0){
                fileStrData += String(fileArrData[i-1]) + ","
            }
            if (i%2 == 0){
                fileStrData += String(fileArrData[i-1]) + "\n"
            }
        }
        print(fileStrData)
        
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
        documentInteraction.presentOpenInMenu(from:  CGRect(x: 10, y: 10, width: 100, height: 50), in: self.view, animated: true)
        
        //documentInteraction.url = FilePath
    
//        text形式で送信
//        let objectsToShare = fileStrData as Any
//        let activityVC = UIActivityViewController(activityItems: [objectsToShare], applicationActivities: nil)
//        activityVC.title = "data.csv"
//        if let wPPC = activityVC.popoverPresentationController {
//            wPPC.sourceView = self.view
//        }
//        present( activityVC, animated: true, completion: nil )
        //self.documentInteraction.presentOpenInMenu(from: self.view.bounds, in: self.view, animated: true)
        
//        if !(documentInteraction?.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true))!
//        {
//            print("3")
//            // 送信できるアプリが見つからなかった時の処理
//            let alert = UIAlertController(title: "送信失敗", message: "ファイルを送れるアプリが見つかりません", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
        
        self.nowgoal_Data=[]
        
    }
}
