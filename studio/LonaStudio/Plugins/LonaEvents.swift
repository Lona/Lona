//
//  LonaEvents.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 12/04/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import FileTree

enum LonaPluginActivationEvent: String, Decodable {
  case onSaveComponent = "onSave:component"
  case onSaveColors = "onSave:colors"
  case onSaveTextStyles = "onSave:textStyles"
  case onReloadWorkspace = "onReload:workspace"
  case onChangeTheme = "onChange:theme"
  case onChangeFileSystemComponents = "onChange:fileSystem:components"
}

class LonaEvents {
  typealias SubscriptionHandle = () -> Void

  class Handler<T> {
    var callback: (T) -> Void

    init(callback: @escaping (T) -> Void) {
      self.callback = callback
    }
  }

  class Event<T> {
    private var handlers: [Handler<T>] = [] as! [LonaEvents.Handler<T>]
    private let eventType: LonaPluginActivationEvent

    init(eventType: LonaPluginActivationEvent) {
      self.eventType = eventType
    }

    func register(handler callback: @escaping (T) -> Void) -> SubscriptionHandle {
      let handler = Handler(callback: callback)

      handlers.append(handler)

      return {
        self.handlers = self.handlers.filter({ $0 !== handler })
      }
    }

    func trigger(_ event: T) {
      LonaPlugins.current.pluginFilesActivatingOn(eventType: eventType).forEach({
        $0.run(onSuccess: {_ in })
      })

      handlers.forEach({ $0.callback(event) })
    }
  }

  static private let onSaveComponentEvent = Event<URL>(eventType: LonaPluginActivationEvent.onSaveComponent)
  static func onSaveComponent(handler callback: @escaping (URL) -> Void) -> SubscriptionHandle {
    return onSaveComponentEvent.register(handler: callback)
  }
  static func triggerSaveComponent(_ event: URL) -> Void {
    return onSaveComponentEvent.trigger(event)
  }

  static private let onSaveColorsEvent = Event<Void>(eventType: LonaPluginActivationEvent.onSaveColors)
  static func onSaveColors(handler callback: @escaping () -> Void) -> SubscriptionHandle {
    return onSaveColorsEvent.register(handler: callback)
  }
  static func triggerSaveColors() -> Void {
    return onSaveColorsEvent.trigger(())
  }

  static private let onSaveTextStylesEvent = Event<Void>(eventType: LonaPluginActivationEvent.onSaveTextStyles)
  static func onSaveTextStyles(handler callback: @escaping () -> Void) -> SubscriptionHandle {
    return onSaveTextStylesEvent.register(handler: callback)
  }
  static func triggerSaveTextStyles() -> Void {
    return onSaveTextStylesEvent.trigger(())
  }

  static private let onReloadWorkspaceEvent = Event<Void>(eventType: LonaPluginActivationEvent.onReloadWorkspace)
  static func onReloadWorkspace(handler callback: @escaping () -> Void) -> SubscriptionHandle {
    return onReloadWorkspaceEvent.register(handler: callback)
  }
  static func triggerReloadWorkspace() -> Void {
    return onReloadWorkspaceEvent.trigger(())
  }

  static private let onChangeThemeEvent = Event<CSValue>(eventType: LonaPluginActivationEvent.onChangeTheme)
  static func onChangeTheme(handler callback: @escaping (CSValue) -> Void) -> SubscriptionHandle {
    return onChangeThemeEvent.register(handler: callback)
  }
  static func triggerChangeTheme(_ event: CSValue) -> Void {
    return onChangeThemeEvent.trigger(event)
  }

  static private let onChangeFileSystemComponentsEvent = Event<[FileTree.Path]>(eventType: LonaPluginActivationEvent.onChangeFileSystemComponents)
  static func onChangeFileSystemComponents(handler callback: @escaping ([FileTree.Path]) -> Void) -> SubscriptionHandle {
    return onChangeFileSystemComponentsEvent.register(handler: callback)
  }
  static func triggerChangeFileSystemComponents(_ event: [FileTree.Path]) -> Void {
    return onChangeFileSystemComponentsEvent.trigger(event)
  }
}
