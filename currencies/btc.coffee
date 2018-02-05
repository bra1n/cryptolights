class BTC
  constructor: ->
    @ws = null
    @socketUrl = "wss://ws.blockchain.info/inv"

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl
    @ws.onopen = =>
      @ws.send JSON.stringify op: 'unconfirmed_sub'
      @ws.send JSON.stringify op: 'blocks_sub'
    @ws.onmessage = ({data}) ->
      data = JSON.parse data
      if data.op is 'utx'
        fee = 0
        valOut = 0
        valIn = 0
        valIn += input.prev_out.value/100000000 for input in data.x.inputs
        valOut += output.value/100000000 for output in data.x.out
        fee = Math.max valIn - valOut, 0
        txCb? {
          amount: valOut
          fee: fee
          link: 'https://blockchain.info/tx/' + data.x.hash
          recipients: data.x.out.map (out) -> [
            out.addr, out.value / 100000000
          ]
        }
      else
        blockCb? data.x
    stop: ->
      @ws.close()
      @ws = null