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
   let notes = MutableProperty<[NoteViewModel]>([NoteViewModel]())
   
   let insertSignal: Signal<NSIndexSet,NoError>
   private let insertSink: Signal<NSIndexSet,NoError>.Observer
   
   let removeSignal: Signal<NSIndexSet,NoError>
   private let removeSink: Signal<NSIndexSet,NoError>.Observer
   
   var addAction: CocoaAction!
   
   override init() {
      
      let (insertPipeSig, insertPipeSink) = Signal<NSIndexSet,NoError>.pipe()
      insertSignal = insertPipeSig
      insertSink   = insertPipeSink
      
      let (removePipeSig, removePipeSink) = Signal<NSIndexSet,NoError>.pipe()
      removeSignal   = removePipeSig
      removeSink = removePipeSink
      
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
      sendNext(insertSink, NSIndexSet(index: 0))
   }
   
   func deleteNoteAtIndex(index: Int) {
      var newNotes = notes.value
      newNotes.removeAtIndex(index)
      notes.put(newNotes)
      sendNext(removeSink, NSIndexSet(index: index))
   }
}
