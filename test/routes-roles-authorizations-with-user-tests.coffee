assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
setupUsers = require './support/setup-users'

describe 'USER IN DB', ->
  server = null

  describe 'with server setup and users', ->

    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          return cb err if err
          setupUsers server,(err) ->
            cb err

    describe 'GET /users/.../authorizations', ->
      describe 'with a non existing user', ->
        it 'should return a 200', (cb) ->
          options =
            method: "GET"
            url: "/users/#{fixtures.user1.id}/authorizations"
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 200
            should.exist result
      
            cb null

    describe 'POST /users/.../authorizations', ->
      describe 'with an existing user and a valid payload', ->
        it 'should return a 201', (cb) ->
          options =
            method: "POST"
            url: "/users/#{fixtures.user1.id}/authorizations"
            payload: fixtures.validAuthorization
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 201
            should.exist result
            console.log JSON.stringify(result)

            cb null

    describe 'DELETE /users/.../authorizations/...', ->
      describe 'with an existing user but non existing authorization', ->
        it 'should return a 204', (cb) ->
          options =
            method: "DELETE"
            url: "/users/#{fixtures.user1.id}/authorizations/#{fixtures.invalidAuthorizationId}"
          server.inject options, (response) ->
            result = response.result

            response.statusCode.should.equal 204
            should.not.exist result
      
            cb null
