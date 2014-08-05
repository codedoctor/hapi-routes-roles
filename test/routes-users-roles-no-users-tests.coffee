assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'

describe 'NO USER IN DB', ->
  server = null

  describe 'with server setup', ->

    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          cb err

    ###
    describe 'GET /users/.../authorizations', ->
      describe 'with a non existing user', ->
        it 'should return a 404', (cb) ->
          options =
            method: "GET"
            url: "/users/#{fixtures.invalidUserId}/authorizations"
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 404
            should.exist result
      
            cb null

    describe 'POST /users/.../authorizations', ->
      describe 'with a non existing user and a valid payload', ->
        it 'should return a 404', (cb) ->
          options =
            method: "POST"
            url: "/users/#{fixtures.invalidUserId}/authorizations"
            payload: fixtures.validAuthorization
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 404
            should.exist result

            cb null

    describe 'DELETE /users/.../authorizations/...', ->
      describe 'with a non existing user', ->
        it 'should return a 204', (cb) ->
          options =
            method: "DELETE"
            url: "/users/#{fixtures.invalidUserId}/authorizations/#{fixtures.invalidAuthorizationId}"
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 204
            should.not.exist result
      
            cb null
    ###
    