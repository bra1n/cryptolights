class LTC
  constructor: ->
    @ws = null
    @socketUrl = "wss://insight.litecore.io/socket.io/?EIO=3&transport=websocket"

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onopen = =>
      @ws.send '2probe'
      @ws.send '5'
      @ws.send '420["subscribe","sync"]'
      @ws.send '421["subscribe","inv"]'
      @ws.send '422["subscribe","sync"]'
      @ws.send '424["subscribe","sync"]'
      @ws.send '425["subscribe","inv"]'
      @ping = setInterval (=> @ws.send '2'), 25*1000

    @ws.onmessage = ({data}) ->
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'tx'
          txCb? {
            amount: payload.valueOut
            fee: 0
            link: 'https://insight.litecore.io/tx/' + payload.txid
            recipients: payload.vout.map (value) -> Object.keys(value)[0]
          }
        else
          blockCb? payload
          
  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null