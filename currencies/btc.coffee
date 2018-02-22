class BTC
  constructor: ->
    @ws = null
    @socketUrl = "wss://ws.blockchain.info/inv"
    @donationAddress = "16DFRg8vsJk1SFevdN1FecDAhmw4Fg4Cip"

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      @ws.send JSON.stringify op: 'unconfirmed_sub'
      @ws.send JSON.stringify op: 'blocks_sub'

    @ws.onmessage = ({data}) =>
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
          donation: !!data.x.out.find (out) => out.addr is @donationAddress
        }
      else
        blockCb? count: data.x.nTx
    stop: ->
      @ws.close()
      @ws = null