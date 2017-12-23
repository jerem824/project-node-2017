should = require 'should'
user = require '../src/users.coffee'

describe 'users', () ->
  it 'saves user', (done) ->
    body = []
    body.login = 'hokayem@gmail.com'
    body.password = '12345678'
    console.log(body)
    user.save body, (err) ->
      should.not.exist err
    done()
