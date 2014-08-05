assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
shouldHttp = require './support/should-http'
shouldRoles = require './support/should-roles'

describe 'NO ROLES IN DB', ->
  server = null

  describe 'with server setup', ->
    beforeEach (cb) ->
      loadServer (err,serverResult) ->
        return cb err if err
        server = serverResult
        setupServer server,(err) ->
          cb err

    describe 'GET /roles', ->
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/roles',null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/roles',fixtures.credentialsUser, cb

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200PagedEmptyResult server,'/roles',fixtures.credentialsServerAdmin, cb


    describe 'POST /roles', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.post server, '/roles', fixtures.role1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.post server, '/roles', fixtures.role1,fixtures.credentialsUser, 403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 201', (cb) ->
          shouldHttp.post server, '/roles', fixtures.role1,fixtures.credentialsServerAdmin,201, (err,response) ->
            return cb err if err
            shouldRoles.isValidServerAdminRole response.result
            cb null


    describe 'DELETE /roles/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/roles/#{fixtures.invalidRoleId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/roles/#{fixtures.invalidRoleId}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/roles/#{fixtures.invalidRoleId}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /roles/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/roles/#{fixtures.invalidRoleId}",fixtures.role1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/roles/#{fixtures.invalidRoleId}",fixtures.role1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.patch server,"/roles/#{fixtures.invalidRoleId}",fixtures.role1,fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err


    describe 'GET /roles/[wrongid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.get server, "/roles/#{fixtures.invalidRoleId}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server, "/roles/#{fixtures.invalidRoleId}",fixtures.credentialsUser,404, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 404', (cb) ->
          shouldHttp.get server,"/roles/#{fixtures.invalidRoleId}",fixtures.credentialsServerAdmin,404, (err,response) ->
            cb err
    