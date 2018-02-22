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

    @ws.onmessage = ({data}) =>
      data = JSON.parse data
      if data.type is 'tx'
        txCb? {
          amount: data.ethers
          fee: data.fee
          link: 'https://etherscan.io/tx/' + data.hash
          donation: data.to is @donationAddress
        }
      else
        blockCb? count: data.transactions

  stop: ->
    @ws.close()
    @ws = null
