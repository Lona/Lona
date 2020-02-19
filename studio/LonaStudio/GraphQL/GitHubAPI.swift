//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

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
