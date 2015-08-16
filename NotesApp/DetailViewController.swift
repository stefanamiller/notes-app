//
//  DetailViewController.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-15.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class DetailViewController: UIViewController {

   @IBOutlet weak var detailDescriptionLabel: UILabel!
   
   lazy var dynamicDescription: DynamicProperty = {
      return DynamicProperty(object: self.detailDescriptionLabel, keyPath: "text")
   }()
   
   let viewModel: NoteViewModel = NoteViewModel()
   
   var detailItem: Note? {
      didSet {
         viewModel.note.put(detailItem)
      }
   }
//   var detailItem: Note? //{
//      didSet {
//         if let note = detailItem {
//            dynamicDescription <~ note.dateStamp
//         }
////          // Update the view.
////          self.configureView()
//      }
//   }

//   func configureView() {
//      // Update the user interface for the detail item.
//      if let note = self.detailItem {
//          if let label = self.detailDescriptionLabel {
//              label.text = note.dateUpdated.value.description
//          }
//      }
//   }

   override func viewDidLoad() {
      super.viewDidLoad()

      dynamicDescription <~ viewModel.dateStamp.producer |> map { $0 as AnyObject? }
      
//      if let note = detailItem {
//         dynamicDescription <~ note.dateStamp.producer |> map { $0 as AnyObject? }
//      }
      
      //RAC(self.detailDescriptionLabel, "text") <~
//      self.rac_valuesForKeyPath("detailItem", observer: self)
      
//      let updatedMapper: Signal<Date, NoError> ~> Signal<String, NoError> = map({
//         date in
//         return date.description
//      })
      
//      detailItem?.dateUpdated.producer
//         |> map {
//            if let date = $0 {
//               return date.description
//            }
//            return ""
//      }
      
//      var sig: Signal = Signal<String, NoError> {
//         sink in
//         return ""
//      }
      
      
//      self.configureView()
   }
   
   func descriptionForDate(date: NSDate) -> String
   {
      return date.description
   }

   override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
   }


}

