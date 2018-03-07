class ETH
  constructor: ->
    @ws = null
    @socketUrl = "wss://ethersocket.herokuapp.com"
    @donationAddress = "0xf3Ac6fFCD6451682a753695e56425038dE2b79DD"

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      #@ws.send '2probe'
      #@ws.send '5'
      #@ping = setInterval (=> @ws.send '2'), 25*1000

    @ws.onmessage = ({data}) =>
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'txsUpdate'
          delay = 1000 / payload.data.pending.length
          for tx in payload.data.pending
            setTimeout (-> txCb? {
                amount: tx.value / 1000000000000000000
                fee: tx.gas * tx.gasPrice / 1000000000000000000
                link: 'https://etherscan.io/tx/0x' + tx.hash_b
                donation: tx.to_b is @donationAddress
              }), delay
            delay += delay
        else
          blockCb? count: payload.data[0].txs.length

  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null
