//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// The possible states for a check suite or run status.
public enum CheckStatusState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The check suite or run has been queued.
  case queued
  /// The check suite or run is in progress.
  case inProgress
  /// The check suite or run has been completed.
  case completed
  /// The check suite or run has been requested.
  case requested
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "QUEUED": self = .queued
      case "IN_PROGRESS": self = .inProgress
      case "COMPLETED": self = .completed
      case "REQUESTED": self = .requested
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .queued: return "QUEUED"
      case .inProgress: return "IN_PROGRESS"
      case .completed: return "COMPLETED"
      case .requested: return "REQUESTED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CheckStatusState, rhs: CheckStatusState) -> Bool {
    switch (lhs, rhs) {
      case (.queued, .queued): return true
      case (.inProgress, .inProgress): return true
      case (.completed, .completed): return true
      case (.requested, .requested): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CheckStatusState] {
    return [
      .queued,
      .inProgress,
      .completed,
      .requested,
    ]
  }
}

/// The possible states for a check suite or run conclusion.
public enum CheckConclusionState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The check suite or run requires action.
  case actionRequired
  /// The check suite or run has timed out.
  case timedOut
  /// The check suite or run has been cancelled.
  case cancelled
  /// The check suite or run has failed.
  case failure
  /// The check suite or run has succeeded.
  case success
  /// The check suite or run was neutral.
  case neutral
  /// The check suite or run was skipped. For internal use only.
  case skipped
  /// The check suite or run was marked stale. For internal use only.
  case stale
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ACTION_REQUIRED": self = .actionRequired
      case "TIMED_OUT": self = .timedOut
      case "CANCELLED": self = .cancelled
      case "FAILURE": self = .failure
      case "SUCCESS": self = .success
      case "NEUTRAL": self = .neutral
      case "SKIPPED": self = .skipped
      case "STALE": self = .stale
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .actionRequired: return "ACTION_REQUIRED"
      case .timedOut: return "TIMED_OUT"
      case .cancelled: return "CANCELLED"
      case .failure: return "FAILURE"
      case .success: return "SUCCESS"
      case .neutral: return "NEUTRAL"
      case .skipped: return "SKIPPED"
      case .stale: return "STALE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: CheckConclusionState, rhs: CheckConclusionState) -> Bool {
    switch (lhs, rhs) {
      case (.actionRequired, .actionRequired): return true
      case (.timedOut, .timedOut): return true
      case (.cancelled, .cancelled): return true
      case (.failure, .failure): return true
      case (.success, .success): return true
      case (.neutral, .neutral): return true
      case (.skipped, .skipped): return true
      case (.stale, .stale): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [CheckConclusionState] {
    return [
      .actionRequired,
      .timedOut,
      .cancelled,
      .failure,
      .success,
      .neutral,
      .skipped,
      .stale,
    ]
  }
}

/// The possible states in which a deployment can be.
public enum DeploymentState: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// The pending deployment was not updated after 30 minutes.
  case abandoned
  /// The deployment is currently active.
  case active
  /// An inactive transient deployment.
  case destroyed
  /// The deployment experienced an error.
  case error
  /// The deployment has failed.
  case failure
  /// The deployment is inactive.
  case inactive
  /// The deployment is pending.
  case pending
  /// The deployment has queued
  case queued
  /// The deployment is in progress.
  case inProgress
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "ABANDONED": self = .abandoned
      case "ACTIVE": self = .active
      case "DESTROYED": self = .destroyed
      case "ERROR": self = .error
      case "FAILURE": self = .failure
      case "INACTIVE": self = .inactive
      case "PENDING": self = .pending
      case "QUEUED": self = .queued
      case "IN_PROGRESS": self = .inProgress
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .abandoned: return "ABANDONED"
      case .active: return "ACTIVE"
      case .destroyed: return "DESTROYED"
      case .error: return "ERROR"
      case .failure: return "FAILURE"
      case .inactive: return "INACTIVE"
      case .pending: return "PENDING"
      case .queued: return "QUEUED"
      case .inProgress: return "IN_PROGRESS"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: DeploymentState, rhs: DeploymentState) -> Bool {
    switch (lhs, rhs) {
      case (.abandoned, .abandoned): return true
      case (.active, .active): return true
      case (.destroyed, .destroyed): return true
      case (.error, .error): return true
      case (.failure, .failure): return true
      case (.inactive, .inactive): return true
      case (.pending, .pending): return true
      case (.queued, .queued): return true
      case (.inProgress, .inProgress): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [DeploymentState] {
    return [
      .abandoned,
      .active,
      .destroyed,
      .error,
      .failure,
      .inactive,
      .pending,
      .queued,
      .inProgress,
    ]
  }
}

public final class CreateRepositoryMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    mutation createRepository($ownerId: ID!, $name: String!, $description: String!) {
      createRepository(input: {ownerId: $ownerId, name: $name, description: $description, visibility: PUBLIC}) {
        __typename
        repository {
          __typename
          url
        }
      }
    }
    """

  public let operationName = "createRepository"

  public var ownerId: GraphQLID
  public var name: String
  public var description: String

  public init(ownerId: GraphQLID, name: String, description: String) {
    self.ownerId = ownerId
    self.name = name
    self.description = description
  }

  public var variables: GraphQLMap? {
    return ["ownerId": ownerId, "name": name, "description": description]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createRepository", arguments: ["input": ["ownerId": GraphQLVariable("ownerId"), "name": GraphQLVariable("name"), "description": GraphQLVariable("description"), "visibility": "PUBLIC"]], type: .object(CreateRepository.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createRepository: CreateRepository? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createRepository": createRepository.flatMap { (value: CreateRepository) -> ResultMap in value.resultMap }])
    }

    /// Create a new repository.
    public var createRepository: CreateRepository? {
      get {
        return (resultMap["createRepository"] as? ResultMap).flatMap { CreateRepository(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "createRepository")
      }
    }

    public struct CreateRepository: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateRepositoryPayload"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("repository", type: .object(Repository.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(repository: Repository? = nil) {
        self.init(unsafeResultMap: ["__typename": "CreateRepositoryPayload", "repository": repository.flatMap { (value: Repository) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The new repository.
      public var repository: Repository? {
        get {
          return (resultMap["repository"] as? ResultMap).flatMap { Repository(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "repository")
        }
      }

      public struct Repository: GraphQLSelectionSet {
        public static let possibleTypes = ["Repository"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String) {
          self.init(unsafeResultMap: ["__typename": "Repository", "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The HTTP URL for this repository
        public var url: String {
          get {
            return resultMap["url"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }
    }
  }
}

public final class GetDeploymentStatusQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    query getDeploymentStatus($owner: String!, $name: String!, $ref: String!) {
      repository(owner: $owner, name: $name) {
        __typename
        ref(qualifiedName: $ref) {
          __typename
          target {
            __typename
            id
            ... on Commit {
              checkSuites(last: 1, filterBy: {appId: 15368}) {
                __typename
                nodes {
                  __typename
                  url
                  checkRuns(first: 10) {
                    __typename
                    nodes {
                      __typename
                      status
                      conclusion
                      name
                    }
                  }
                  status
                  conclusion
                }
              }
            }
          }
        }
        deployments(last: 10) {
          __typename
          nodes {
            __typename
            commit {
              __typename
              id
            }
            environment
            state
            latestStatus {
              __typename
              environmentUrl
            }
          }
        }
      }
    }
    """

  public let operationName = "getDeploymentStatus"

  public var owner: String
  public var name: String
  public var ref: String

  public init(owner: String, name: String, ref: String) {
    self.owner = owner
    self.name = name
    self.ref = ref
  }

  public var variables: GraphQLMap? {
    return ["owner": owner, "name": name, "ref": ref]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("repository", arguments: ["owner": GraphQLVariable("owner"), "name": GraphQLVariable("name")], type: .object(Repository.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(repository: Repository? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "repository": repository.flatMap { (value: Repository) -> ResultMap in value.resultMap }])
    }

    /// Lookup a given repository by the owner and repository name.
    public var repository: Repository? {
      get {
        return (resultMap["repository"] as? ResultMap).flatMap { Repository(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "repository")
      }
    }

    public struct Repository: GraphQLSelectionSet {
      public static let possibleTypes = ["Repository"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("ref", arguments: ["qualifiedName": GraphQLVariable("ref")], type: .object(Ref.selections)),
        GraphQLField("deployments", arguments: ["last": 10], type: .nonNull(.object(Deployment.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(ref: Ref? = nil, deployments: Deployment) {
        self.init(unsafeResultMap: ["__typename": "Repository", "ref": ref.flatMap { (value: Ref) -> ResultMap in value.resultMap }, "deployments": deployments.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Fetch a given ref from the repository
      public var ref: Ref? {
        get {
          return (resultMap["ref"] as? ResultMap).flatMap { Ref(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "ref")
        }
      }

      /// Deployments associated with the repository
      public var deployments: Deployment {
        get {
          return Deployment(unsafeResultMap: resultMap["deployments"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "deployments")
        }
      }

      public struct Ref: GraphQLSelectionSet {
        public static let possibleTypes = ["Ref"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("target", type: .nonNull(.object(Target.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(target: Target) {
          self.init(unsafeResultMap: ["__typename": "Ref", "target": target.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The object the ref points to.
        public var target: Target {
          get {
            return Target(unsafeResultMap: resultMap["target"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "target")
          }
        }

        public struct Target: GraphQLSelectionSet {
          public static let possibleTypes = ["Commit", "Tree", "Blob", "Tag"]

          public static let selections: [GraphQLSelection] = [
            GraphQLTypeCase(
              variants: ["Commit": AsCommit.selections],
              default: [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              ]
            )
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public static func makeTree(id: GraphQLID) -> Target {
            return Target(unsafeResultMap: ["__typename": "Tree", "id": id])
          }

          public static func makeBlob(id: GraphQLID) -> Target {
            return Target(unsafeResultMap: ["__typename": "Blob", "id": id])
          }

          public static func makeTag(id: GraphQLID) -> Target {
            return Target(unsafeResultMap: ["__typename": "Tag", "id": id])
          }

          public static func makeCommit(id: GraphQLID, checkSuites: AsCommit.CheckSuite? = nil) -> Target {
            return Target(unsafeResultMap: ["__typename": "Commit", "id": id, "checkSuites": checkSuites.flatMap { (value: AsCommit.CheckSuite) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var asCommit: AsCommit? {
            get {
              if !AsCommit.possibleTypes.contains(__typename) { return nil }
              return AsCommit(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap = newValue.resultMap
            }
          }

          public struct AsCommit: GraphQLSelectionSet {
            public static let possibleTypes = ["Commit"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("checkSuites", arguments: ["last": 1, "filterBy": ["appId": 15368]], type: .object(CheckSuite.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, checkSuites: CheckSuite? = nil) {
              self.init(unsafeResultMap: ["__typename": "Commit", "id": id, "checkSuites": checkSuites.flatMap { (value: CheckSuite) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            /// The check suites associated with a commit.
            public var checkSuites: CheckSuite? {
              get {
                return (resultMap["checkSuites"] as? ResultMap).flatMap { CheckSuite(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "checkSuites")
              }
            }

            public struct CheckSuite: GraphQLSelectionSet {
              public static let possibleTypes = ["CheckSuiteConnection"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("nodes", type: .list(.object(Node.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(nodes: [Node?]? = nil) {
                self.init(unsafeResultMap: ["__typename": "CheckSuiteConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// A list of nodes.
              public var nodes: [Node?]? {
                get {
                  return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
                }
                set {
                  resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
                }
              }

              public struct Node: GraphQLSelectionSet {
                public static let possibleTypes = ["CheckSuite"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("url", type: .nonNull(.scalar(String.self))),
                  GraphQLField("checkRuns", arguments: ["first": 10], type: .object(CheckRun.selections)),
                  GraphQLField("status", type: .nonNull(.scalar(CheckStatusState.self))),
                  GraphQLField("conclusion", type: .scalar(CheckConclusionState.self)),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(url: String, checkRuns: CheckRun? = nil, status: CheckStatusState, conclusion: CheckConclusionState? = nil) {
                  self.init(unsafeResultMap: ["__typename": "CheckSuite", "url": url, "checkRuns": checkRuns.flatMap { (value: CheckRun) -> ResultMap in value.resultMap }, "status": status, "conclusion": conclusion])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// The HTTP URL for this check suite
                public var url: String {
                  get {
                    return resultMap["url"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "url")
                  }
                }

                /// The check runs associated with a check suite.
                public var checkRuns: CheckRun? {
                  get {
                    return (resultMap["checkRuns"] as? ResultMap).flatMap { CheckRun(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "checkRuns")
                  }
                }

                /// The status of this check suite.
                public var status: CheckStatusState {
                  get {
                    return resultMap["status"]! as! CheckStatusState
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "status")
                  }
                }

                /// The conclusion of this check suite.
                public var conclusion: CheckConclusionState? {
                  get {
                    return resultMap["conclusion"] as? CheckConclusionState
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "conclusion")
                  }
                }

                public struct CheckRun: GraphQLSelectionSet {
                  public static let possibleTypes = ["CheckRunConnection"]

                  public static let selections: [GraphQLSelection] = [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("nodes", type: .list(.object(Node.selections))),
                  ]

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(nodes: [Node?]? = nil) {
                    self.init(unsafeResultMap: ["__typename": "CheckRunConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// A list of nodes.
                  public var nodes: [Node?]? {
                    get {
                      return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
                    }
                    set {
                      resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
                    }
                  }

                  public struct Node: GraphQLSelectionSet {
                    public static let possibleTypes = ["CheckRun"]

                    public static let selections: [GraphQLSelection] = [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("status", type: .nonNull(.scalar(CheckStatusState.self))),
                      GraphQLField("conclusion", type: .scalar(CheckConclusionState.self)),
                      GraphQLField("name", type: .nonNull(.scalar(String.self))),
                    ]

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(status: CheckStatusState, conclusion: CheckConclusionState? = nil, name: String) {
                      self.init(unsafeResultMap: ["__typename": "CheckRun", "status": status, "conclusion": conclusion, "name": name])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// The current status of the check run.
                    public var status: CheckStatusState {
                      get {
                        return resultMap["status"]! as! CheckStatusState
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "status")
                      }
                    }

                    /// The conclusion of the check run.
                    public var conclusion: CheckConclusionState? {
                      get {
                        return resultMap["conclusion"] as? CheckConclusionState
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "conclusion")
                      }
                    }

                    /// The name of the check for this check run.
                    public var name: String {
                      get {
                        return resultMap["name"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "name")
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }

      public struct Deployment: GraphQLSelectionSet {
        public static let possibleTypes = ["DeploymentConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nodes", type: .list(.object(Node.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(nodes: [Node?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "DeploymentConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// A list of nodes.
        public var nodes: [Node?]? {
          get {
            return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Deployment"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("commit", type: .object(Commit.selections)),
            GraphQLField("environment", type: .scalar(String.self)),
            GraphQLField("state", type: .scalar(DeploymentState.self)),
            GraphQLField("latestStatus", type: .object(LatestStatus.selections)),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(commit: Commit? = nil, environment: String? = nil, state: DeploymentState? = nil, latestStatus: LatestStatus? = nil) {
            self.init(unsafeResultMap: ["__typename": "Deployment", "commit": commit.flatMap { (value: Commit) -> ResultMap in value.resultMap }, "environment": environment, "state": state, "latestStatus": latestStatus.flatMap { (value: LatestStatus) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Identifies the commit sha of the deployment.
          public var commit: Commit? {
            get {
              return (resultMap["commit"] as? ResultMap).flatMap { Commit(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "commit")
            }
          }

          /// The latest environment to which this deployment was made.
          public var environment: String? {
            get {
              return resultMap["environment"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "environment")
            }
          }

          /// The current state of the deployment.
          public var state: DeploymentState? {
            get {
              return resultMap["state"] as? DeploymentState
            }
            set {
              resultMap.updateValue(newValue, forKey: "state")
            }
          }

          /// The latest status of this deployment.
          public var latestStatus: LatestStatus? {
            get {
              return (resultMap["latestStatus"] as? ResultMap).flatMap { LatestStatus(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "latestStatus")
            }
          }

          public struct Commit: GraphQLSelectionSet {
            public static let possibleTypes = ["Commit"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID) {
              self.init(unsafeResultMap: ["__typename": "Commit", "id": id])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }
          }

          public struct LatestStatus: GraphQLSelectionSet {
            public static let possibleTypes = ["DeploymentStatus"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("environmentUrl", type: .scalar(String.self)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(environmentUrl: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "DeploymentStatus", "environmentUrl": environmentUrl])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Identifies the environment URL of the deployment.
            public var environmentUrl: String? {
              get {
                return resultMap["environmentUrl"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "environmentUrl")
              }
            }
          }
        }
      }
    }
  }
}

public final class GetOrganizationsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    query getOrganizations {
      viewer {
        __typename
        id
        login
        organizations(first: 100) {
          __typename
          nodes {
            __typename
            id
            login
            viewerCanCreateRepositories
          }
        }
      }
    }
    """

  public let operationName = "getOrganizations"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("viewer", type: .nonNull(.object(Viewer.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(viewer: Viewer) {
      self.init(unsafeResultMap: ["__typename": "Query", "viewer": viewer.resultMap])
    }

    /// The currently authenticated user.
    public var viewer: Viewer {
      get {
        return Viewer(unsafeResultMap: resultMap["viewer"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "viewer")
      }
    }

    public struct Viewer: GraphQLSelectionSet {
      public static let possibleTypes = ["User"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("login", type: .nonNull(.scalar(String.self))),
        GraphQLField("organizations", arguments: ["first": 100], type: .nonNull(.object(Organization.selections))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, login: String, organizations: Organization) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "login": login, "organizations": organizations.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// The username used to login.
      public var login: String {
        get {
          return resultMap["login"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "login")
        }
      }

      /// A list of organizations the user belongs to.
      public var organizations: Organization {
        get {
          return Organization(unsafeResultMap: resultMap["organizations"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "organizations")
        }
      }

      public struct Organization: GraphQLSelectionSet {
        public static let possibleTypes = ["OrganizationConnection"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("nodes", type: .list(.object(Node.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(nodes: [Node?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "OrganizationConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// A list of nodes.
        public var nodes: [Node?]? {
          get {
            return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes = ["Organization"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("login", type: .nonNull(.scalar(String.self))),
            GraphQLField("viewerCanCreateRepositories", type: .nonNull(.scalar(Bool.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, login: String, viewerCanCreateRepositories: Bool) {
            self.init(unsafeResultMap: ["__typename": "Organization", "id": id, "login": login, "viewerCanCreateRepositories": viewerCanCreateRepositories])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          /// The organization's login name.
          public var login: String {
            get {
              return resultMap["login"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "login")
            }
          }

          /// Viewer can create repositories on this organization
          public var viewerCanCreateRepositories: Bool {
            get {
              return resultMap["viewerCanCreateRepositories"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "viewerCanCreateRepositories")
            }
          }
        }
      }
    }
  }
}
