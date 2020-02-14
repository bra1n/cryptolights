# CryptoLights 
Live transaction visualization for Bitcoin, Ethereum, Litecoin, Ripple and Nano

https://cryptolights.info

## Explanation

Payments made through modern crypto currencies are broadcast to the internet where everyone
can track them. This website takes advantage of that and show a "meteor" descending from the top
of the page for every transaction that is sent through the network. These transactions are considered
"unconfirmed" until a new block (on the blockchain) is "mined", confirming these transactions. Ripple and Nano are an exception here,
because they use a different approach to verify and store transactions.

Whenever a transaction is sent, a meteor will be created in the lane of the corresponding currency.
Depending on the Dollar volume of the transaction, the meteor will have a certain color and size. For currencies that
require a fee to send a transaction, the meteor will also have a "trail" with a length relative to the size of the fees 
that were paid for this transaction. The same applies to the speed of the meteor - higher transaction fees will make it 
go faster and also increase the chance to be confirmed in a shorter amount of time.

Every now and then, you will see a blue bar descend in the lanes of BTC, ETH or LTC. This bar represents a block that
has just been mined. It will have a height depending on the number of confirmed transactions within that block. Ripple and Nano
don't have a centralised blockchain and thus lack network-wide blocks.

Each meteor can also be clicked on to see the transaction that it is based on. 

### Meteor sizes / colors and transaction volumes

The meteor size and color is based on the amount of money being transferred. (except for donations)
Ethereum contract transactions and Ripple IOUs usually don't transfer any money (so the transaction volume is $0).
Transactions above $1 million will still grow in size but won't change colors beyond red.

Color | Size | Transaction volume
------|------|-------------------
Blue  | 5px-20px | $0 - $100           
Turquoise | 20px-30px| $100 - $1000  
Green | 30px-40px | $1000 - $10,000           
Yellow | 40px-50px | $10,000 - $100,000       
Orange | 50px-60px | $100,000 - $1,000,000   
Red    | 60px+ | $1,000,000+             

### Meteor trails

Meteor trail lengths are not capped, but scale logarithmically like meteor sizes.

Trail Length | Transaction Fee
-------|------
0px    | $0
10px   | $0.01 - $0.3
15px   | $0.5
25px   | $1
40px   | $2
60px   | $4
85px   | $10
140px  | $50

## CryptoLights screensaver

To set the website up as a screensaver, you'll usually need a third-party tool.
Once you have the screensaver tool installed, simply use `http://cryptolights.info/#nohelp` as the URL.
This will prevent the help overlay (and navigation icons) from showing on the screensaver.
The following links should provide you with a way to set up a screensaver for this website:

- Windows: https://github.com/cwc/web-page-screensaver
- MacOS: https://github.com/liquidx/webviewscreensaver
- Ubuntu: https://github.com/lmartinking/webscreensaver

## Contributing

This website was built with [Coffeescript](http://coffeescript.org/), CSS and HTML. You'll need a Coffeescript compiler
to generate the JS files. Maybe I'll add some Gulp tasks in the future to simplify compiling and deployment.
If you want to see your favorite crypto currency added to the list, you'll need a public websocket where each transaction (and block, if there
are any) is broadcast. Then simply copy one of the implementations in `/currencies`, change the API and callbacks and
adjust the HTML and CSS accordingly. If everything works fine, you're probably also going to need the logo of your coin as a background
image for the new meteor lane. Apart from that, feel free to modify the code however you like and open pull requests or issues for 
features you'd like to see implemented!

## Acknowledgements

This visualisation is implementing on the following APIs:

- **Bitcoin:** https://blockchain.info
- **Ethereum:** http://www.amberdata.io/
- **Ripple:** http://www.ripple.com/
- **Litecoin:** https://insight.litecore.io/
- **Nano:** https://www.nanocrawler.cc/
- **Prices:** https://www.cryptocompare.com/api/ and https://coinlore.com/

Furthermore, it uses Google Webfonts and Material Icons.
