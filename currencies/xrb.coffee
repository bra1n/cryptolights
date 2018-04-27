class XRB
  constructor: ->
    @ws = null
    @socketUrl = "wss://www.nanode.co/socket.io/?EIO=3&transport=websocket"
    @donationAddress = "xrb_1em33f7ewc9mpbargkp14m3uuojz5wt96hzu4tcfb585ds8575gp1fnoxaj3"

  start: (txCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      @ping = setInterval (=> @ws.send '2'), 25*1000

    @ws.onmessage = ({data}) =>
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'block' and (payload.type is 'send' or payload.type is 'receive')
          txCb? {
            amount: payload.amount / Math.pow(10, 30)
            fee: 0
            link: 'https://www.nanode.co/block/' + payload.hash
            donation: payload.account is @donationAddress
          }

  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null
