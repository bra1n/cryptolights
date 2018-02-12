class ETH
  constructor: ->
    @ws = null
    @socketUrl = "wss://ethersocket.herokuapp.com"
    @donationAddress = ""

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl
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
        blockCb? data

  stop: ->
    @ws.close()
    @ws = null