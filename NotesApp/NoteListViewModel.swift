//
//  NoteListViewModel.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-18.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteListViewModel: NSObject {
   typealias IndicesChangeSignal = Signal<Int,NoError>
   
   let notes = MutableProperty<[NoteViewModel]>([NoteViewModel]())
   
   let insertSignal: IndicesChangeSignal
   let removeSignal: IndicesChangeSignal
   
   var addAction: CocoaAction!
   
   private let insertSink: IndicesChangeSignal.Observer
   private let removeSink: IndicesChangeSignal.Observer
   override init() {
      
      let (insertPipeSig, insertPipeSink) = IndicesChangeSignal.pipe()
      insertSignal = insertPipeSig
      insertSink   = insertPipeSink
      
      let (removePipeSig, removePipeSink) = IndicesChangeSignal.pipe()
      removeSignal = removePipeSig
      removeSink   = removePipeSink
      
      super.init()
      
      let action = Action<UIBarButtonItem, Void, NoError> { [weak self] button in
         NSLog("Add Action!!!")
         self!.createNewNote()
         return SignalProducer.empty
      }
      addAction = action.unsafeCocoaAction
   }
   
   deinit {
      sendCompleted(insertSink)
      sendCompleted(removeSink)
   }
   
   func countOfNotes() -> Int {
      return notes.value.count
   }
   
   func noteViewModelAtIndex(index: Int) -> NoteViewModel {
      return notes.value[index]
   }
   
   func createNewNote() {
      var newNotes = notes.value
      newNotes.insert(NoteViewModel(Note()), atIndex: 0)
      notes.put(newNotes)
      sendNext(insertSink, 0)
   }
   
   func deleteNoteAtIndex(index: Int) {
      var newNotes = notes.value
      newNotes.removeAtIndex(index)
      notes.put(newNotes)
      sendNext(removeSink, index)
   }
}
