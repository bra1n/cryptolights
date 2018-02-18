class XRB
  constructor: ->
    @ws = null
    @socketUrl = "wss://www.nanode.co/socket.io/?EIO=3&transport=websocket"
    @donationAddress = "xrb_1ac4dntxugbfxsmmy6wimddwiju7em7qi6zp8ri6fx566swq4j56gwd9ibxw"

  start: (txCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl
    @ws.onopen = =>
      @ping = setInterval (=> @ws.send '2'), 25*1000
    @ws.onmessage = ({data}) =>
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'block' and payload.type is 'receive' # receive contains recipient address
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