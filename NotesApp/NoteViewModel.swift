//
//  NoteViewModel.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-18.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteViewModel: NSObject {
   private let noteMutator = MutableProperty<Note?>(nil)
   var note: Note? { get {
      if let note = noteMutator.value {
         return note.copy()
      } else {
         return nil
      }
   }}
   
   private(set) var updateSignal: Signal<NoteViewModel,NoError>!
   
   let dateStamp = MutableProperty<String>("")
   let noteBody  = MutableProperty<String?>("")
   
   let editingEnabled: ConstantProperty<Bool>
   
   init(_ n: Note?) {
      editingEnabled = ConstantProperty(n != nil)
      super.init()
      
      setupBindings()
      self.noteMutator.put(n)
      
      observeUpdate()
   }
   
   convenience override init() {
      self.init(nil)
   }
   
   private func observeUpdate() {
      noteMutator.producer.startWithSignal { [weak self] signal, disposable in
         self!.updateSignal = signal |> map { note in
            return self!
         }
         signal |> observe(completed: {
            disposable.dispose()
         })
      }
   }
   
   private func setupBindings() {
      dateStamp <~ noteMutator.producer
         |> ignoreNil
         |> map { note in
            note.dateUpdated
         }
         //         |> on(next: { date in
         //            NSLog("Formatting date \(date)")
         //         })
         |> self.formatUpdatedDate()
      
      noteBody <~ noteMutator.producer
         |> ignoreNil
         |> map { note in
            note.body
         }
         |> on(next: { value in
            NSLog("Updated note body!")
         })
   }
   
   func formatUpdatedDate() -> Signal<NSDate, NoError> -> Signal<String, NoError> {
      return map { date in
         self.formatUpdatedDate(date)
      }
   }
   
   func formatUpdatedDate(date: NSDate) -> String {
      if NSCalendar.currentCalendar().isDateInToday(date) {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .NoStyle, timeStyle: .MediumStyle)
      }
      else {
         return NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .MediumStyle)
      }
   }
}
