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
   
   lazy var updatedText: DynamicProperty! = DynamicProperty(object: self.detailDescriptionLabel, keyPath: "text")
   lazy var bodyTextChange: DynamicProperty! = DynamicProperty(object: self.bodyTextView, keyPath: "text")
   
   var viewModel: NoteViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      if (viewModel == nil) {
         viewModel = NoteViewModel()
      }
      setupBindings()
   }
   
   func bindViewModel(vm: NoteViewModel) {
      viewModel = vm
      if (self.isViewLoaded()) {
         setupBindings()
      }
   }
   
   func setupBindings() {
      
      updatedText <~ viewModel.dateStamp.producer
         |> on(next: { next in
            NSLog("Note Date: \(next)");
         })
         |> map { $0 as AnyObject? }
      
      bodyTextChange <~ viewModel.noteBody.producer |> map { $0 as AnyObject? }
      
      bodyTextView.rac_textSignal().asSignal()
         |> observe (next: typedText) // Ideally we would bind the signal to the updateText function directly, not sure how to do this
   }

   func typedText(text: AnyObject?) {
      let str = text as? String
      if let vm = viewModel {
         vm.updateText(str)
      }
   }
}

