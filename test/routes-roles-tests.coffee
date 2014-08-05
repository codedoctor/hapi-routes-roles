assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
setupRoles = require './support/setup-roles'
shouldHttp = require './support/should-http'

describe 'ROLES IN DB', ->
  server = null

  describe 'with server setup and users', ->

    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          return cb err if err
          setupRoles server,(err) ->
            cb err

    describe 'GET /roles', ->
      describe 'with no roles in the db', ->
        describe 'WITHOUT CREDENTIALS', ->
          it 'should return a 200', (cb) ->
            options =
              method: "GET"
              url: "/roles"
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 200
              should.exist result
              ###
              @TODO check paged result
              ###
        
              cb null

###

        describe 'WITH CREDENTIALS', ->
          it 'should return a 200', (cb) ->
            options =
              method: "GET"
              url: "/roles"
              credentials: fixtures.credentialsUser
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 200
              should.exist result
              ##
              @TODO check paged result
              ##
        
              cb null

        describe 'WITH ADMIN CREDENTIALS', ->
          it 'should return a 200', (cb) ->
            options =
              method: "GET"
              url: "/roles"
              credentials: fixtures.credentialsAdmin
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 200
              should.exist result
              ##
              @TODO check paged result
              ##
        
              cb null


    describe 'POST /roles', ->
      describe 'WITHOUT CREDENTIALS', ->
        describe 'with a valid payload should create a role', ->
          it 'should return a 201', (cb) ->
            options =
              method: "POST"
              url: "/roles"
              payload: fixtures.role1
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 201
              should.exist result
              console.log JSON.stringify(result)

              cb null

      describe 'WITH CREDENTIALS', ->
        describe 'with a valid payload should create a role', ->
          it 'should return a 201', (cb) ->
            options =
              method: "POST"
              url: "/roles"
              payload: fixtures.role2
              credentials: fixtures.credentialsUser
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 201
              should.exist result
              console.log JSON.stringify(result)

              cb null

      describe 'WITH ADMIN CREDENTIALS', ->
        describe 'with a valid payload should create a role', ->
          it 'should return a 201', (cb) ->
            options =
              method: "POST"
              url: "/roles"
              payload: fixtures.roleInternal1
              credentials: fixtures.credentialsADmin
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 201
              should.exist result
              console.log JSON.stringify(result)

              cb null

    describe 'DELETE /roles', ->
      describe 'WITH CREDENTIALS', ->
        describe 'with an invalid roleId', ->
          it 'should return a 401', (cb) -> # Or 403???
            options =
              method: "DELETE"
              url: "/roles/#{fixtures.invalidRoleId}"
              credentials: fixtures.credentialsUser
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 204
              should.not.exist result
      
            cb null

      describe 'WITH ADMIN CREDENTIALS', ->
        describe 'with an invalid roleId', ->
          it 'should return a 204', (cb) ->
            options =
              method: "DELETE"
              url: "/roles/#{fixtures.invalidRoleId}"
              credentials: fixtures.credentialsAdmin
            server.inject options, (response) ->
              result = response.result

              response.statusCode.should.equal 204
              should.not.exist result
      
            cb null
###

