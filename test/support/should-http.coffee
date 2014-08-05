should = require 'should'

module.exports =
  get200PagedEmptyResult: (server,pathWithRoot,credentials,cb) ->
    options =
      method: "GET"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal 200
      should.exist response.result
      response.result.should.have.property "totalCount",0

      cb null,response

  get200Paged: (server,pathWithRoot,resultCount,credentials,cb) ->
    options =
      method: "GET"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal 200    
      should.exist response.result

      cb null,response

  get401: (server,pathWithRoot,cb) ->
    options =
      method: "GET"
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null

  post401: (server,pathWithRoot,payload,credentials,cb) ->
    options =
      method: "POST"
      url: pathWithRoot
      credentials: credentials
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null,response

  post403: (server,pathWithRoot,payload,credentials,cb) ->
    options =
      method: "POST"
      url: pathWithRoot
      credentials: credentials
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal 403
      cb null,response

  post201: (server,pathWithRoot,payload,credentials,cb) ->
    options =
      method: "POST"
      payload: payload
      credentials: credentials
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 201  
      cb null,response
      

  patch: (server,pathWithRoot,payload,credentials,statusCode = 200,cb) ->
    options =
      method: "PATCH"
      url: pathWithRoot
      credentials : credentials
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal statusCode
      cb null,response
 
  delete: (server,pathWithRoot,credentials,statusCode = 200,cb) ->
    options =
      method: "DELETE"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal statusCode
      cb null,response

