class ETH
  constructor: ->
    @ws = null
    # wss://ws.blockchain.info/coins - unconfirmed TX
    # wss://etherscan.io/wshandler - blocks
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
      data = JSON.parse data
      if data.from?
        txCb? {
          amount: data.value / 1000000000000000000
          fee: data.gas * data.gasPrice / 1000000000000000000
          link: 'https://etherscan.io/tx/0x' + data.hash.substr 2
          donation: data.to is @donationAddress
        }
      else
        blockCb? count: data.numTransactions

  stop: ->
    @ws.close()
    #clearInterval @ping
    @ws = null
