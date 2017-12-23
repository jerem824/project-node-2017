level = require 'level'
levelws = require 'level-ws'
passwordHash = require 'password-hash'

db = levelws level "#{__dirname}/../dbuser"

module.exports =

  checkuser: (body, callback) ->
    rs = db.createReadStream()
    result = null
    name = null
    {login,password} =  body
    patt_email = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/i
    patt_password = /^.{8,}$/i
    test_email = patt_email.test(login);
    test_password = patt_password.test(password);
    if test_email == true && test_password == true
      rs.on 'data', (data) ->
        [id,email] = data.key.split ":"
        if login == email
          check_password = passwordHash.verify(password, data.value)
          if check_password == true
            result = id
            name = email
      rs.on 'error', (err) -> callback(err)
      rs.on 'close', -> callback(null, result, name)

  save: (body, callback) ->
    {login,password} =  body
    patt_email = /^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,3}$/i
    patt_password = /^.{8,}$/i
    test_email = patt_email.test(login);
    test_password = patt_password.test(password);
    if test_email == true && test_password == true
      hashed_password = passwordHash.generate(password)
      password = hashed_password
      rs = db.createReadStream()
      highestid = 1
      rs.on 'data', (data) ->
        highestid += 1
      rs.on 'close', ->
        db.put("#{highestid}:#{login}", password)
        callback(null, 1)
