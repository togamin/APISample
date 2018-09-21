//
//  ViewController.swift
//  APISample
//
//  Created by Togami Yuki on 2018/09/21.
//  Copyright © 2018 Togami Yuki. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    let margin:CGFloat = 3.0
    var musicList = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //カスタムセルでxibファイルを使う
        self.collectionView.register(UINib(nibName:"CollectionViewCell",bundle:nil),forCellWithReuseIdentifier:"Cell")
        
        /*API------------------------------------------------*/
        //使える文字列を指定
        let allowedCharacterSet = CharacterSet.alphanumerics
        
        //ituesからデータを取得する.後で変えやすいように別々にしている。
        let word = "Greeeen".addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        let num = 30
        let urlStr = "https://itunes.apple.com/search?term=\(word!)&limit=\(num)"
        
        let url = URL(string: urlStr)!
        let request = URLRequest(url:url)
        
        let dispatchGroup = DispatchGroup()//非同期処理
        dispatchGroup.enter()
        
        //URLSessionはdataをダウンロードする時に使う
        let task = URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        
                        self.musicList = json["results"] as! [[String:Any]]
                        dispatchGroup.leave()
                        
                        //print(self.musicList[0])
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        //enter内の処理が全て終わったら実行される
        dispatchGroup.notify(queue: .main, execute: {
            self.collectionView.reloadData()
        })
        
        task.resume()
        
        /*------------------------------------------------*/
    }

    //セルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.musicList.count
    }
    
    //セルのインスタンス化
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let url = URL(string:musicList[indexPath.row]["artworkUrl100"] as! String)
        let imageData:Data = (try! Data(contentsOf:url!,options: NSData.ReadingOptions.mappedIfSafe))
        cell.imageView.image = UIImage(data:imageData)
        cell.myLabel.text = musicList[indexPath.row]["trackName"] as? String
        
        return cell
    }
    //セルのサイズ指定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width//画面の横側
        let cellNum:CGFloat = 3
        let cellSize = (width - margin * (cellNum + 1))/cellNum//一個あたりのサイズ
        return CGSize(width:cellSize,height:cellSize)
    }
    //セル同士の縦の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    //セル同士の横の間隔を決める。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

