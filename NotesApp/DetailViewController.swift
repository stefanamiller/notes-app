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
   @IBOutlet weak var bodyTextView: UITextView!
   
   lazy var dynamicDescription: DynamicProperty! = DynamicProperty(object: self.detailDescriptionLabel, keyPath: "text")
   lazy var bodyTextChange: DynamicProperty! = DynamicProperty(object: self.bodyTextView, keyPath: "text")
   
   let viewModel: NoteViewModel = NoteViewModel()
   
   var note: Note? {
      didSet {
         viewModel.note.put(note)
      }
   }

   override func viewDidLoad() {
      super.viewDidLoad()

      dynamicDescription <~ viewModel.dateStamp.producer
         |> on(next: { next in
            NSLog("Note Date: \(next)");
            })
         |> map { $0 as AnyObject? }
      
      bodyTextChange <~ viewModel.noteBody.producer
         |> map { $0 as AnyObject? }
      
      bodyTextView.rac_textSignal().asSignal()
         |> observe(next: { [weak viewModel] value in
            NSLog("\(value)")
            let str = value as? String
            if let vm = viewModel {
               vm.updateText(str)
            }
         })
      
//      viewModel.noteBody <~ bodyTextChange.producer
//         |> on { value in
//            NSLog("Text changed to \(value)")
//         }
//         |> map { $0 as! String }
//      viewModel.noteBody <~ bodyTextView.rac_textSignal().toSignalProducer()
//         |> ignoreNil
//         |> map { $0 as? String }

//      let textMap: SignalProducer<AnyObject, NoError> -> SignalProducer<String, NoError> = map { $0 as! String }
      
//      viewModel.noteBody <~ textSignal
      
//      let textSignal = bodyTextView.rac_textSignal().asSignal()
//      textSignal |> observe( next: { value in
//         NSLog("\(value)")
//      })
//      viewModel.noteBody <~ bodyTextView.rac_textSignal().asSignal()
//      viewModel.noteBody <~ bodyView.rac_textSignal().toSignalProducer()
//      bodyTextView.rac_textSignal().toSignalProducer()
//         |> ignoreNil
//         |> on(event: { next in
//            NSLog("Next: \(next)");
//         })

//      bodyTextView.rac_textSignal().subscribeNext { (x) -> Void in
//         NSLog("\(x)")
//      }
//      bodyTextView.rac_textSignal().asSignal()
//         |> observe(next: { next in
//            NSLog("\(next)")
//      })
//      bodyTextView.rac_textSignal().toSignalProducer()
//         |> on(event: { event in
//            NSLog("Body text event")
//            }, next: { next in
//            NSLog("Next: \(next)")
//         })
//         |> map { text in
//            NSLog("\(text)")
//      }
//      bodyTextChange.producer
//         |> on(event: { event in
//            NSLog("Observed body text change")
//      })
      
   }

}

