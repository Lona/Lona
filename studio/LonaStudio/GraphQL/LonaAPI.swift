//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public enum RepoOrigin: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case gitHub
  case gitHubEnterprise
  case other
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "GitHub": self = .gitHub
      case "GitHubEnterprise": self = .gitHubEnterprise
      case "Other": self = .other
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .gitHub: return "GitHub"
      case .gitHubEnterprise: return "GitHubEnterprise"
      case .other: return "Other"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: RepoOrigin, rhs: RepoOrigin) -> Bool {
    switch (lhs, rhs) {
      case (.gitHub, .gitHub): return true
      case (.gitHubEnterprise, .gitHubEnterprise): return true
      case (.other, .other): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [RepoOrigin] {
    return [
      .gitHub,
      .gitHubEnterprise,
      .other,
    ]
  }
}

public final class AddRepoMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    mutation addRepo($organisationId: ID!, $url: String!) {
      addRepo(organisationId: $organisationId, url: $url) {
        __typename
        success
        message
        repo {
          __typename
          url
          activated
          origin
        }
      }
    }
    """

  public let operationName = "addRepo"

  public var organisationId: GraphQLID
  public var url: String

  public init(organisationId: GraphQLID, url: String) {
    self.organisationId = organisationId
    self.url = url
  }

  public var variables: GraphQLMap? {
    return ["organisationId": organisationId, "url": url]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("addRepo", arguments: ["organisationId": GraphQLVariable("organisationId"), "url": GraphQLVariable("url")], type: .object(AddRepo.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(addRepo: AddRepo? = nil) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "addRepo": addRepo.flatMap { (value: AddRepo) -> ResultMap in value.resultMap }])
    }

    public var addRepo: AddRepo? {
      get {
        return (resultMap["addRepo"] as? ResultMap).flatMap { AddRepo(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "addRepo")
      }
    }

    public struct AddRepo: GraphQLSelectionSet {
      public static let possibleTypes = ["AddRepoMutationResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("message", type: .nonNull(.scalar(String.self))),
        GraphQLField("repo", type: .object(Repo.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool, message: String, repo: Repo? = nil) {
        self.init(unsafeResultMap: ["__typename": "AddRepoMutationResponse", "success": success, "message": message, "repo": repo.flatMap { (value: Repo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
        get {
          return resultMap["success"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }

      public var message: String {
        get {
          return resultMap["message"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "message")
        }
      }

      public var repo: Repo? {
        get {
          return (resultMap["repo"] as? ResultMap).flatMap { Repo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "repo")
        }
      }

      public struct Repo: GraphQLSelectionSet {
        public static let possibleTypes = ["Repo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
          GraphQLField("activated", type: .nonNull(.scalar(Bool.self))),
          GraphQLField("origin", type: .nonNull(.scalar(RepoOrigin.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(url: String, activated: Bool, origin: RepoOrigin) {
          self.init(unsafeResultMap: ["__typename": "Repo", "url": url, "activated": activated, "origin": origin])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var url: String {
          get {
            return resultMap["url"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }

        public var activated: Bool {
          get {
            return resultMap["activated"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "activated")
          }
        }

        public var origin: RepoOrigin {
          get {
            return resultMap["origin"]! as! RepoOrigin
          }
          set {
            resultMap.updateValue(newValue, forKey: "origin")
          }
        }
      }
    }
  }
}

public final class CreateOrganisationMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    mutation createOrganisation($name: String!) {
      createOrganisation(name: $name) {
        __typename
        success
        message
        organisation {
          __typename
          id
          name
        }
      }
    }
    """

  public let operationName = "createOrganisation"

  public var name: String

  public init(name: String) {
    self.name = name
  }

  public var variables: GraphQLMap? {
    return ["name": name]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Mutation"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("createOrganisation", arguments: ["name": GraphQLVariable("name")], type: .nonNull(.object(CreateOrganisation.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(createOrganisation: CreateOrganisation) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "createOrganisation": createOrganisation.resultMap])
    }

    public var createOrganisation: CreateOrganisation {
      get {
        return CreateOrganisation(unsafeResultMap: resultMap["createOrganisation"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "createOrganisation")
      }
    }

    public struct CreateOrganisation: GraphQLSelectionSet {
      public static let possibleTypes = ["CreateOrganisationMutationResponse"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("success", type: .nonNull(.scalar(Bool.self))),
        GraphQLField("message", type: .nonNull(.scalar(String.self))),
        GraphQLField("organisation", type: .object(Organisation.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(success: Bool, message: String, organisation: Organisation? = nil) {
        self.init(unsafeResultMap: ["__typename": "CreateOrganisationMutationResponse", "success": success, "message": message, "organisation": organisation.flatMap { (value: Organisation) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var success: Bool {
        get {
          return resultMap["success"]! as! Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "success")
        }
      }

      public var message: String {
        get {
          return resultMap["message"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "message")
        }
      }

      public var organisation: Organisation? {
        get {
          return (resultMap["organisation"] as? ResultMap).flatMap { Organisation(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "organisation")
        }
      }

      public struct Organisation: GraphQLSelectionSet {
        public static let possibleTypes = ["Organisation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String) {
          self.init(unsafeResultMap: ["__typename": "Organisation", "id": id, "name": name])
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

public final class GetMeQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition =
    """
    query getMe {
      getMe {
        __typename
        id
        username
        token
        githubAccessToken
        organisations {
          __typename
          id
          name
          repos {
            __typename
            url
            activated
          }
        }
      }
    }
    """

  public let operationName = "getMe"

  public init() {
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes = ["Query"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("getMe", type: .object(GetMe.selections)),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getMe: GetMe? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getMe": getMe.flatMap { (value: GetMe) -> ResultMap in value.resultMap }])
    }

    public var getMe: GetMe? {
      get {
        return (resultMap["getMe"] as? ResultMap).flatMap { GetMe(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getMe")
      }
    }

    public struct GetMe: GraphQLSelectionSet {
      public static let possibleTypes = ["Me"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("username", type: .scalar(String.self)),
        GraphQLField("token", type: .nonNull(.scalar(String.self))),
        GraphQLField("githubAccessToken", type: .scalar(String.self)),
        GraphQLField("organisations", type: .nonNull(.list(.nonNull(.object(Organisation.selections))))),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, username: String? = nil, token: String, githubAccessToken: String? = nil, organisations: [Organisation]) {
        self.init(unsafeResultMap: ["__typename": "Me", "id": id, "username": username, "token": token, "githubAccessToken": githubAccessToken, "organisations": organisations.map { (value: Organisation) -> ResultMap in value.resultMap }])
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

      public var username: String? {
        get {
          return resultMap["username"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "username")
        }
      }

      public var token: String {
        get {
          return resultMap["token"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "token")
        }
      }

      public var githubAccessToken: String? {
        get {
          return resultMap["githubAccessToken"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "githubAccessToken")
        }
      }

      public var organisations: [Organisation] {
        get {
          return (resultMap["organisations"] as! [ResultMap]).map { (value: ResultMap) -> Organisation in Organisation(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Organisation) -> ResultMap in value.resultMap }, forKey: "organisations")
        }
      }

      public struct Organisation: GraphQLSelectionSet {
        public static let possibleTypes = ["Organisation"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("name", type: .nonNull(.scalar(String.self))),
          GraphQLField("repos", type: .nonNull(.list(.nonNull(.object(Repo.selections))))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String, repos: [Repo]) {
          self.init(unsafeResultMap: ["__typename": "Organisation", "id": id, "name": name, "repos": repos.map { (value: Repo) -> ResultMap in value.resultMap }])
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

        public var name: String {
          get {
            return resultMap["name"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        public var repos: [Repo] {
          get {
            return (resultMap["repos"] as! [ResultMap]).map { (value: ResultMap) -> Repo in Repo(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Repo) -> ResultMap in value.resultMap }, forKey: "repos")
          }
        }

        public struct Repo: GraphQLSelectionSet {
          public static let possibleTypes = ["Repo"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("url", type: .nonNull(.scalar(String.self))),
            GraphQLField("activated", type: .nonNull(.scalar(Bool.self))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(url: String, activated: Bool) {
            self.init(unsafeResultMap: ["__typename": "Repo", "url": url, "activated": activated])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var url: String {
            get {
              return resultMap["url"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }

          public var activated: Bool {
            get {
              return resultMap["activated"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "activated")
            }
          }
        }
      }
    }
  }
}
