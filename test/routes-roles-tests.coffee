assert = require 'assert'
should = require 'should'

fixtures = require './support/fixtures'
loadServer = require './support/load-server'
setupServer = require './support/setup-server'
setupRoles = require './support/setup-roles'
shouldHttp = require './support/should-http'

describe 'roles in db', ->
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
      describe 'with NO credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/roles',2,null, cb

      describe 'with USER credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/roles',2,fixtures.credentialsUser, (err,response) ->
            return cb err if err

            for item in response.result.items
              item.should.have.property "_url"
              item.should.have.property "name"
              item.should.have.property "description"
              item.should.have.property "id"

              item.should.not.have.property "isInternal"
              item.should.not.have.property "accountId"

            cb null


      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.get200Paged server,'/roles',3,fixtures.credentialsServerAdmin, (err,response) ->
            return cb err if err

            for item in response.result.items
              item.should.have.property "_url"
              item.should.have.property "name"
              item.should.have.property "description"
              item.should.have.property "id"

              item.should.have.property "isInternal"
              item.should.have.property "accountId"

            cb null

    describe 'DELETE /roles/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.delete server, "/roles/#{fixtures.role1.id}",null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.delete server, "/roles/#{fixtures.role1.id}",fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 204', (cb) ->
          shouldHttp.delete server,"/roles/#{fixtures.role1.id}",fixtures.credentialsServerAdmin,204, (err,response) ->
            cb err

    describe 'PATCH /roles/[validid]', ->
      describe 'with NO credentials', ->
        it 'should return a 401', (cb) ->
          shouldHttp.patch server, "/roles/#{fixtures.role1.id}",fixtures.role1,null,401, (err,response) ->
            cb err

      describe 'with USER credentials', ->
        it 'should return a 403', (cb) ->
          shouldHttp.patch server, "/roles/#{fixtures.role1.id}",fixtures.role1,fixtures.credentialsUser,403, (err,response) ->
            cb err

      describe 'with SERVER ADMIN credentials', ->
        it 'should return a 200', (cb) ->
          shouldHttp.patch server,"/roles/#{fixtures.role1.id}",fixtures.role1,fixtures.credentialsServerAdmin,200, (err,response) ->
            cb err

