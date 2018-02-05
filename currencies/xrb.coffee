class XRB
  constructor: ->
    @ws = null
    @socketUrl = "wss://www.nanode.co/socket.io/?EIO=3&transport=websocket"

  start: (txCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl
    @ws.onopen = =>
      @ping = setInterval (=> @ws.send '2'), 25*1000
    @ws.onmessage = ({data}) ->
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'block'
          txCb? {
            amount: payload.amount / Math.pow(10, 30)
            fee: 0
            link: 'https://www.nanode.co/block/' + payload.hash
            recipients: [payload.account]
          }

  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null