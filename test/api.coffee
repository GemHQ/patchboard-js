# Imaginary API of a GitHub knockoff

urn = (name) ->
  "urn:gh-knockoff##{name}"

search_query =
  match:
    type: "string"
  limit:
    type: "integer"
  offset:
    type: "integer"
  sort:
    type: "string"
    enum: ["asc", "desc"]

exports.media_type = media_type = (name) ->
  "application/vnd.gh-knockoff.#{name}+json;version=1.0"

exports.mappings =
 
  authenticated_user:
    path: "/user"
    resource: "user"
 
  user:
    resource: "user"
    template: "/user/:login"

  user_search:
    path: "/user"
    resource: "user_search"
    query: search_query
 
  repositories:
    description: "Repositories for the authenticated user"
    path: "/user/repos"
    resource: "repositories"
  
  user_repositories:
    template: "/user/:login/repos"
    resource: "repositories"
  
  repository:
    resource: "repository"
    template: "/repos/:login/:name"
  
  repo_search:
    path: "/repos"
    query: search_query
    resource: "repo_search"


exports.resources =

  user:
    actions:
      get:
        method: "GET"
        response_schema: urn "user"
        status: 200
      update:
        method: "PUT"
        request_schema: urn "user"
        response_schema: urn "user"
        status: 200

  user_search:
    actions:
      get:
        method: "GET"
        response_schema: urn "user_list"
        status: 200

  repository:
    actions:
      get:
        method: "GET"
        response_schema: urn "repository"
        status: 200

      update:
        method: "PUT"
        response_schema: urn "repository"
        status: 200

      delete:
        method: "DELETE", status: 204

  repo_search:
    actions:
      get:
        method: "GET"
        response_schema: urn "repository_list"
        status: 200

  repositories:
    actions:
      create:
        method: "POST"
        request_schema: urn "repository"
        status: 201

  ref:
    actions:
      get:
        method: "GET"
        response_schema: urn "reference"
        status: 200

  branch:
    actions:
      get:
        method: "GET"
        response_schema: urn "reference"
        status: 200
      rename:
        method: "POST"
        status: 200
      delete:
        method: "DELETE"
        status: 204

  tag:
    actions:
      get:
        method: "GET"
        response_schema: urn "reference"
        status: 200
      delete:
        method: "DELETE"
        status: 204


exports.schema =
  id: "urn:gh-knockoff"
  # This is the conventional place to store schema definitions,
  # becoming official as of Draft 04
  definitions:

    resource:
      type: "object"
      properties:
        url:
          type: "string"
          format: "uri"

    user:
      extends: {$ref: "#/definitions/resource"}
      mediaType: media_type("user")
      properties:
        login: {type: "string"}
        name: {type: "string"}
        email: {type: "string"}

    user_list:
      mediaType: media_type("user_list")
      type: "array"
      items: {$ref: "#/definitions/user"}


    repository:
      extends: {$ref: "#/definitions/resource"}
      mediaType: media_type("repository")
      properties:
        name: {type: "string"}
        login: {type: "string"}
        owner: {$ref: "#/definitions/user"}
        description: {type: "string"}
        refs:
          type: "object"
          properties:
            main: {$ref: "#/definitions/branch"}
            branches:
              type: "object"
              additionalProperties: {$ref: "#/definitions/branch"}
            tags:
              type: "array"
              items: {$ref: "#/definitions/tag"}

    repository_list:
      mediaType: media_type("repository_list")
      type: "array"
      items: {$ref: "#/definitions/repository"}


    reference:
      extends: {$ref: "#/definitions/resource"}
      mediaType: media_type("reference")
      properties:
        commit:
          required: true
          type: "string"
        message:
          required: true
          type: "string"

    branch:
      extends: {$ref: "#/definitions/reference"}
      mediaType: media_type("branch")
      properties:
        name:
          required: true
          type: "string"

    tag:
      extends: {$ref: "#/definitions/reference"}
      mediaType: media_type("tag")
      properties:
        name:
          required: true
          type: "string"


