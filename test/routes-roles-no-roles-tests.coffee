assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
shouldHttp = require './support/should-http'

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
          shouldHttp.post401 server, '/roles', fixtures.role1,null, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.post403 server, '/roles', fixtures.role1,fixtures.credentialsUser, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 201', (cb) ->
          shouldHttp.post201 server, '/roles', fixtures.role1,fixtures.credentialsServerAdmin, (err,response) ->
            return cb err if err
            item = response.result
            item.should.have.property "_url"
            item.should.have.property "name"
            item.should.have.property "description"
            item.should.have.property "id"

            item.should.have.property "isInternal"
            item.should.have.property "accountId"
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

    