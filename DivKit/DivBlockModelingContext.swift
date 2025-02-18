import CoreGraphics

import BasePublic
import BaseUIPublic
import LayoutKit
import NetworkingPublic

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public struct DivBlockModelingContext {
  let viewId: DivViewId
  private(set) var cardLogId: String?
  private(set) var parentDivStatePath: DivStatePath?
  let stateManager: DivStateManager
  public let blockStateStorage: DivBlockStateStorage
  let visibilityCounter: DivVisibilityCounting
  let lastVisibleBoundsCache: DivLastVisibleBoundsCache
  public let imageHolderFactory: DivImageHolderFactory
  let highPriorityImageHolderFactory: DivImageHolderFactory?
  let divCustomBlockFactory: DivCustomBlockFactory
  let fontProvider: DivFontProvider
  let flagsInfo: DivFlagsInfo
  let extensionHandlers: [String: DivExtensionHandler]
  let stateInterceptors: [String: DivStateInterceptor]
  let layoutDirection: UserInterfaceLayoutDirection
  let debugParams: DebugParams
  let scheduler: Scheduling
  let playerFactory: PlayerFactory?
  private(set) weak var parentScrollView: ScrollView?
  public private(set) var errorsStorage: DivErrorsStorage
  private let persistentValuesStorage: DivPersistentValuesStorage
  let tooltipViewFactory: DivTooltipViewFactory?
  public let variablesStorage: DivVariablesStorage
  public private(set) var expressionResolver: ExpressionResolver
  private var functionsProvider: FunctionsProvider
  private let variableTracker: ExpressionResolver.VariableTracker
  public private(set) var parentPath: UIElementPath
  private(set) var sizeModifier: DivSizeModifier?
  private(set) var prototypesStorage = [String: AnyHashable]()

  public init(
    cardId: DivCardID,
    additionalId: String? = nil,
    cardLogId: String? = nil,
    parentPath: UIElementPath? = nil,
    parentDivStatePath: DivStatePath? = nil,
    stateManager: DivStateManager,
    blockStateStorage: DivBlockStateStorage = DivBlockStateStorage(),
    visibilityCounter: DivVisibilityCounting? = nil,
    lastVisibleBoundsCache: DivLastVisibleBoundsCache? = nil,
    imageHolderFactory: DivImageHolderFactory,
    highPriorityImageHolderFactory: DivImageHolderFactory? = nil,
    divCustomBlockFactory: DivCustomBlockFactory? = nil,
    fontProvider: DivFontProvider? = nil,
    flagsInfo: DivFlagsInfo = .default,
    extensionHandlers: [DivExtensionHandler] = [],
    stateInterceptors: [DivStateInterceptor] = [],
    variablesStorage: DivVariablesStorage = DivVariablesStorage(),
    playerFactory: PlayerFactory? = nil,
    debugParams: DebugParams = DebugParams(),
    scheduler: Scheduling? = nil,
    parentScrollView: ScrollView? = nil,
    errorsStorage: DivErrorsStorage? = nil,
    layoutDirection: UserInterfaceLayoutDirection = .leftToRight,
    variableTracker: DivVariableTracker? = nil,
    persistentValuesStorage: DivPersistentValuesStorage? = nil,
    tooltipViewFactory: DivTooltipViewFactory? = nil
  ) {
    let viewId = DivViewId(cardId: cardId, additionalId: additionalId)
    let variableTracker: ExpressionResolver.VariableTracker = { variables in
      variableTracker?.onVariablesUsed(id: viewId, variables: variables)
    }
    var extensionsHandlersDictionary = [String: DivExtensionHandler]()
    extensionHandlers.forEach {
      let id = $0.id
      if extensionsHandlersDictionary[id] != nil {
        DivKitLogger.failure("Duplicate DivExtensionHandler for: \(id)")
        return
      }
      extensionsHandlersDictionary[id] = $0
    }
    var stateInterceptorsDictionary = [String: DivStateInterceptor]()
    stateInterceptors.forEach {
      let id = $0.id
      if stateInterceptorsDictionary[id] != nil {
        DivKitLogger.failure("Duplicate DivStateInterceptor for: \(id)")
        return
      }
      stateInterceptorsDictionary[id] = $0
    }
    self.init(
      viewId: viewId,
      cardLogId: cardLogId,
      parentPath: parentPath,
      parentDivStatePath: parentDivStatePath,
      stateManager: stateManager,
      blockStateStorage: blockStateStorage,
      visibilityCounter: visibilityCounter,
      lastVisibleBoundsCache: lastVisibleBoundsCache,
      imageHolderFactory: imageHolderFactory,
      highPriorityImageHolderFactory: highPriorityImageHolderFactory,
      divCustomBlockFactory: divCustomBlockFactory,
      fontProvider: fontProvider,
      flagsInfo: flagsInfo,
      extensionHandlers: extensionsHandlersDictionary,
      stateInterceptors: stateInterceptorsDictionary,
      variablesStorage: variablesStorage,
      playerFactory: playerFactory,
      debugParams: debugParams,
      scheduler: scheduler,
      parentScrollView: parentScrollView,
      errorsStorage: errorsStorage,
      layoutDirection: layoutDirection,
      variableTracker: variableTracker,
      persistentValuesStorage: persistentValuesStorage,
      tooltipViewFactory: tooltipViewFactory
    )
  }

  init(
    viewId: DivViewId,
    cardLogId: String?,
    parentPath: UIElementPath?,
    parentDivStatePath: DivStatePath?,
    stateManager: DivStateManager,
    blockStateStorage: DivBlockStateStorage,
    visibilityCounter: DivVisibilityCounting?,
    lastVisibleBoundsCache: DivLastVisibleBoundsCache?,
    imageHolderFactory: DivImageHolderFactory,
    highPriorityImageHolderFactory: DivImageHolderFactory?,
    divCustomBlockFactory: DivCustomBlockFactory?,
    fontProvider: DivFontProvider?,
    flagsInfo: DivFlagsInfo,
    extensionHandlers: [String: DivExtensionHandler],
    stateInterceptors: [String: DivStateInterceptor],
    variablesStorage: DivVariablesStorage,
    playerFactory: PlayerFactory?,
    debugParams: DebugParams,
    scheduler: Scheduling?,
    parentScrollView: ScrollView?,
    errorsStorage: DivErrorsStorage?,
    layoutDirection: UserInterfaceLayoutDirection,
    variableTracker: @escaping ExpressionResolver.VariableTracker,
    persistentValuesStorage: DivPersistentValuesStorage?,
    tooltipViewFactory: DivTooltipViewFactory?
  ) {
    self.viewId = viewId
    self.cardLogId = cardLogId
    let cardId = viewId.cardId
    let parentPath = parentPath ?? UIElementPath(cardId.rawValue)
    self.parentPath = parentPath
    self.parentDivStatePath = parentDivStatePath
    self.stateManager = stateManager
    self.blockStateStorage = blockStateStorage
    self.visibilityCounter = visibilityCounter ?? DivVisibilityCounter()
    self.lastVisibleBoundsCache = lastVisibleBoundsCache ?? DivLastVisibleBoundsCache()
    self.imageHolderFactory = imageHolderFactory
    self.highPriorityImageHolderFactory = highPriorityImageHolderFactory
    self.divCustomBlockFactory = divCustomBlockFactory ?? EmptyDivCustomBlockFactory()
    self.flagsInfo = flagsInfo
    self.fontProvider = fontProvider ?? DefaultFontProvider()
    self.playerFactory = playerFactory
    self.debugParams = debugParams
    self.scheduler = scheduler ?? TimerScheduler()
    self.parentScrollView = parentScrollView
    self.errorsStorage = errorsStorage ?? DivErrorsStorage(errors: [])
    self.layoutDirection = layoutDirection
    self.variableTracker = variableTracker
    let persistentValuesStorage = persistentValuesStorage ?? DivPersistentValuesStorage()
    self.persistentValuesStorage = persistentValuesStorage
    self.tooltipViewFactory = tooltipViewFactory
    self.variablesStorage = variablesStorage
    self.extensionHandlers = extensionHandlers
    self.stateInterceptors = stateInterceptors
    functionsProvider = FunctionsProvider(
      cardId: cardId,
      variablesStorage: variablesStorage,
      variableTracker: variableTracker,
      persistentValuesStorage: persistentValuesStorage
    )
    expressionResolver = makeExpressionResolver(
      functionsProvider: functionsProvider,
      parentPath: parentPath,
      errorsStorage: errorsStorage
    )
  }

  public var cardId: DivCardID {
    viewId.cardId
  }
  
  public func getExtensionHandlers(for div: DivBase) -> [DivExtensionHandler] {
    guard let extensions = div.extensions else {
      return []
    }
    return extensions.compactMap {
      let id = $0.id
      if !extensionHandlers.keys.contains(id), !stateInterceptors.keys.contains(id) {
        addError(message: "No DivExtensionHandler for: \(id)")
      }
      return extensionHandlers[id]
    }
  }

  public func getStateInterceptor(for divState: DivState) -> DivStateInterceptor? {
    divState.extensions?.compactMap { stateInterceptors[$0.id] }.first
  }

  public func addError(message: String) {
    errorsStorage.add(DivBlockModelingError(message, path: parentPath))
  }

  public func addWarning(message: String) {
    errorsStorage.add(DivBlockModelingWarning(message, path: parentPath))
  }

  func addError(error: Error) {
    if let divError = error as? DivError {
      errorsStorage.add(divError)
      return
    }
    errorsStorage.add(DivUnknownError(error, path: parentPath))
  }

  func makeBinding<T>(variableName: String?, defaultValue: T) -> Binding<T> {
    guard let variableName else {
      return Binding(name: "", value: Property(initialValue: defaultValue))
    }

    let divVariableName = DivVariableName(rawValue: variableName)
    variableTracker([divVariableName])
    let value: T = variablesStorage
      .getVariableValue(cardId: cardId, name: divVariableName) ?? defaultValue
    let valueProp = Property<T>(
      getter: { value },
      setter: {
        guard let newValue = DivVariableValue($0) else { return }
        self.variablesStorage.update(
          cardId: cardId,
          name: divVariableName,
          value: newValue
        )
      }
    )
    return Binding(name: variableName, value: valueProp)
  }
}

extension DivBlockModelingContext {
  func modifying(
    cardLogId: String? = nil,
    parentPath: UIElementPath? = nil,
    parentDivStatePath: DivStatePath? = nil,
    errorsStorage: DivErrorsStorage? = nil,
    sizeModifier: DivSizeModifier? = nil,
    prototypesData: (String, [String: AnyHashable])? = nil
  ) -> Self {
    var context = self
    if let cardLogId {
      context.cardLogId = cardLogId
    }
    if let parentDivStatePath {
      context.parentDivStatePath = parentDivStatePath
    }
    if let sizeModifier {
      context.sizeModifier = sizeModifier
    }

    if parentPath == nil, errorsStorage == nil, prototypesData == nil {
      return context
    }

    let functionsProvider: FunctionsProvider
    if let prototypesData {
      var prototypesStorage = self.prototypesStorage
      prototypesStorage[prototypesData.0] = prototypesData.1
      functionsProvider = FunctionsProvider(
        cardId: cardId,
        variablesStorage: variablesStorage,
        variableTracker: variableTracker,
        persistentValuesStorage: persistentValuesStorage,
        prototypesStorage: prototypesStorage
      )
      context.prototypesStorage = prototypesStorage
      context.functionsProvider = functionsProvider
    } else {
      functionsProvider = self.functionsProvider
    }

    let parentPath = parentPath ?? self.parentPath
    let errorsStorage = errorsStorage ?? self.errorsStorage
    context.expressionResolver = makeExpressionResolver(
      functionsProvider: functionsProvider,
      parentPath: parentPath,
      errorsStorage: errorsStorage
    )
    context.parentPath = parentPath
    context.errorsStorage = errorsStorage

    return context
  }
}

private func makeExpressionResolver(
  functionsProvider: FunctionsProvider,
  parentPath: UIElementPath,
  errorsStorage: DivErrorsStorage?
) -> ExpressionResolver {
  ExpressionResolver(
    functionsProvider: functionsProvider,
    errorTracker: { [weak errorsStorage] error in
      errorsStorage?.add(DivExpressionError(error, path: parentPath))
    }
  )
}
