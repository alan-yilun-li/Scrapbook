//
//  LibraryViewController.swift
//  Scrapbook
//
//  Created by Dev User on 2017-07-20.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var scrapbookCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrapbookCollectionView.delegate = self
        scrapbookCollectionView.dataSource = self 
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LibraryViewController: UICollectionViewDelegate {
    
}

extension LibraryViewController: UICollectionViewDataSource {
    @available(iOS 6.0, *)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScrapbookCell", for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}



















