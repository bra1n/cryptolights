currencies =
  btc: new BTC()
  eth: new ETH()
  ltc: new LTC()
  xrb: new XRB()
prices = {}
lanes = {}

# render TX
showTx = (currency, tx) ->
  price = tx.amount*prices[currency]
  fee = tx.fee*prices[currency]

  lanes[currency].addMeteor
    speed: if fee then 2 + 4 * Math.min(2, Math.log10(1+fee))/2 else 6
    hue: if price then 220 - 220 * Math.min(6, Math.log10(1+price))/6 else 220
    thickness: Math.max(5, Math.log10(1+price) * 10)
    length: Math.min(3, Math.log10(1 + fee))/3 * 250
    link: tx.link

# render block
showBlock = (currency) ->
  lanes[currency].addBlock()

# get current price
updatePrices = (currencies) ->
  currencyAPI = 'https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms='
  $.get currencyAPI + currencies.join(',').toUpperCase(), (data) ->
    if data
      for currency, price of data
        currency = currency.toLowerCase()
        prices[currency] = Math.round(1/price*100)/100
        $('.'+currency+' .price').text prices[currency]

  setTimeout updatePrices.bind(null, currencies), 10*1000

# start everything
$ ->
  updatePrices Object.keys(currencies)
  $('.currencies > div').each ->
    currency = $(@).attr 'class'
    if currencies[currency]?
      currencies[currency].start showTx.bind(null, currency), showBlock.bind(null, currency)
      canvas = $ '<canvas></canvas>'
      $('.'+currency).append canvas
      lanes[currency] = new CanvasRenderer canvas.get(0)