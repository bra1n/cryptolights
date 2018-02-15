currencies =
  btc: new BTC()
  eth: new ETH()
  ltc: new LTC()
  xrb: new XRB()
prices = {}
lanes = {}
stats = {}

# render TX
showTx = (currency, tx) ->
  value = tx.amount * (prices[currency] or 1)
  fee = tx.fee * (prices[currency] or 1)

  lanes[currency].addMeteor
    speed: if fee then 2 + 4 * Math.min(2, Math.log10(1+fee))/2 else 6
    hue: if value then 220 - 220 * Math.min(6, Math.log10(1+value))/6 else 220
    thickness: Math.max(5, Math.log10(1+value) * 10)
    length: Math.min(3, Math.log10(1 + fee))/3 * 250
    link: tx.link
    donation: tx.donation

  updateStats currency, value, fee

# render block
showBlock = (currency, block) ->
  lanes[currency].addBlock Math.min(250, block.count / 4)
  stats[currency].count = Math.max(0, stats[currency].count - block.count) if stats[currency]?

# get current price
updatePrices = (currencies) ->
  currencyAPI = 'https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms='
  $.get currencyAPI + currencies.join(',').toUpperCase(), (data) ->
    if data
      for currency, price of data
        currency = currency.toLowerCase()
        prices[currency] = Math.round(1/price*100)/100
        $(".#{currency} .price").text prices[currency].toLocaleString(undefined, { style: 'currency', currency: 'USD' })

  setTimeout updatePrices.bind(null, currencies), 10*1000

# update stats for a currency, called whenever there is a new TX
# to do that, keep a log of the last 60 seconds of tx
updateStats = (currency, value = 0, fee = 0) ->
  stats[currency] = {last: [], count: 0} unless stats[currency]?
  # increase number of unverified TX
  stats[currency].count++ unless currency is 'xrb'
  # calculate stats for last 60s
  last = stats[currency].last
  timestamp = new Date().getTime()
  last.push {timestamp, value, fee}
  i = last.length
  last.splice(i, 1) while i-- when timestamp - last[i].timestamp > 60*1000
  duration = Math.max(last[last.length - 1].timestamp - last[0].timestamp, 1) / 1000
  txPerSecond = Math.round(last.length / duration * 10)/10
  #valuePerSecond = Math.round(stat.reduce(((a, b) -> a + b.value), 0) / duration)
  valuePerTx = Math.round(last.reduce(((a, b) -> a + b.value), 0) / last.length)
  #feePerSecond = Math.round(stat.reduce(((a, b) -> a + b.fee), 0) / duration * 100)/100
  feePerTx = Math.round(last.reduce(((a, b) -> a + b.fee), 0) / last.length * 100)/100
  $(".#{currency} .stats").text """
    #{txPerSecond.toLocaleString()} tx/s (#{stats[currency].count} unconfirmed)
    #{valuePerTx.toLocaleString(undefined, { style: 'currency', minimumFractionDigits: 0, maximumFractionDigits:0, currency: 'USD' })} value/tx
    #{feePerTx.toLocaleString(undefined, { style: 'currency', currency: 'USD' })} fee/tx
  """

# start everything
$ ->
  updatePrices Object.keys(currencies)
  $('.overlay').hide().on 'click', (e) ->
    $(this).fadeOut() if $(e.target).is('.overlay')
  $('.currencies > div').each ->
    currency = $(@).attr 'class'
    if currencies[currency]?
      currencies[currency].start showTx.bind(null, currency), showBlock.bind(null, currency)
      canvas = $ '<canvas></canvas>'
      $('.'+currency).append canvas
      lanes[currency] = new CanvasRenderer canvas.get(0)

      # donation links
      if currencies[currency].donationAddress
        $(this).find('.donate').on 'click', =>
          $('.overlay').fadeToggle().find('.address').text currencies[currency].donationAddress
      else
        $(this).find('.donate').remove()
