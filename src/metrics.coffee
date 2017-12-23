level = require 'level'
levelws = require 'level-ws'

db = levelws level "#{__dirname}/../dbmetrics"

module.exports =
  # get(id, callback)
  # Get metrics
  # - id: metric's id
  # - callback: the callback function, callback(err, data)
  get: (id, callback) ->
    rs = db.createReadStream()
    # read
    result = []
    rs.on 'data', (data) ->
      [_, key_id, ts] = data.key.split ":"
      if "#{id}" == key_id
        result.push
          timestamp: ts
          value: data.value
    rs.on 'error', (err) -> callback(err)
    rs.on 'close', -> callback(null, result)


  # save(id, metrics, callback)
  # Save given metrics
  # - id: metric id
  # - metrics: an array of { timestamp, value }
  # - callback: the callback function
  save: (id, metrics, callback) ->
    ws = db.createWriteStream()
    ws.on 'error', callback
    ws.on 'close', callback
    for metric in metrics
      { timestamp, value } =  metric
      ws.write
        key: "metrics:#{id}:#{timestamp}"
        value: value
    ws.end()

  add: (id, metrics, callback) ->
    db.put("metrics:#{id}:#{metrics.ts}", metrics.val)
    callback(null)

  delete: (id, ts, callback) ->
    db.del("metrics:#{id}:#{ts}")
    callback(null)
