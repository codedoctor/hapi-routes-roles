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

      cb null

  get200Paged: (server,pathWithRoot,resultCount,credentials,cb) ->
    options =
      method: "GET"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal 200    
      should.exist response.result
      response.result.should.have.property "totalCount",resultCount
      console.log JSON.stringify(response.result) 

      cb null

  get401: (server,pathWithRoot,cb) ->
    options =
      method: "GET"
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null

  post401: (server,pathWithRoot,payload,cb) ->
    options =
      method: "POST"
      url: pathWithRoot
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null

  post201: (server,pathWithRoot,payload,credentials,cb) ->
    options =
      method: "POST"
      payload: payload
      credentials: credentials
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 201  
      cb null
      

  patch200: (server,pathWithRoot,credentials,payload = {},cb) ->
    options =
      method: "PATCH"
      url: pathWithRoot
      credentials : credentials
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal 200
      cb null,response
      
  patch401: (server,pathWithRoot,cb) ->
    options =
      method: "PATCH"
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null


  patch404: (server,pathWithRoot,credentials,payload = {},cb) ->
    options =
      method: "PATCH"
      url: pathWithRoot
      credentials : credentials
      payload: payload

    server.inject options, (response) ->
      response.statusCode.should.equal 404
      cb null

  delete200: (server,pathWithRoot,credentials,cb) ->
    options =
      method: "DELETE"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal 200 
      cb null

  ###
  A 204 should be returned if a delete happened, but no content is returned (most likely because the deleted object has already been deleted)
  ###
  delete204: (server,pathWithRoot,credentials,cb) ->
    options =
      method: "DELETE"
      url: pathWithRoot
      credentials: credentials

    server.inject options, (response) ->
      response.statusCode.should.equal 204 
      cb null

  ###
  A 401 on deleted should be returned when a delete operation is not authorized.
  ###
  delete401: (server,pathWithRoot,cb) ->
    options =
      method: "DELETE"
      url: pathWithRoot

    server.inject options, (response) ->
      response.statusCode.should.equal 401  
      cb null

