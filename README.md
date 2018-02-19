# CryptoLights 
Live transaction visualization for Bitcoin, Ethereum, Litecoin and Nano

https://cryptolights.info

## Explanation

Payments made through modern crypto currencies are broadcast to the internet where everyone
can track them. This website takes advantage of that and show a "meteor" descending from the top
of the page for every transaction that is sent through the network. These transactions are considered
"unconfirmed" until a new block (on the blockchain) is "mined", confirming these transactions. Nano is an exception here,
because every wallet has its own blockchain, which means transactions are usually confirmed instantly by the network.

Whenever a transaction is sent, a meteor will be created in the lane of the corresponding currency.
Depending on the Dollar volume of the transaction, the meteor will have a certain color and size. For currencies that
require a fee to send a transaction, the meteor will also have a "trail" with a length relative to the size of the fees 
that were paid for this transaction. The same applies to the speed of the meteor - higher transaction fees will make it 
go faster and also increase the chance to be confirmed in a shorter amount of time.

Every now and then, you will see a blue bar descend in the lanes of BTC, ETH or LTC. This bar represents a block that
has just been mined. It will have a height depending on the number of confirmed transactions within that block. Nano
doesn't have a centralised blockchain and thus lacks network-wide blocks.

Each meteor can also be clicked on to see the transaction that it is based on. 

### Meteor sizes / colors and transaction volumes

The meteor size and color is based on the amount of money being transfered. (except for donations)
Ethereum contract transactions usually don't transfer any money (so the transaction volume is $0).
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

### Windows 10

http://www.ilovefreesoftware.com/25/windows-10/set-webpage-screensaver-windows-10.html

### MacOS

https://github.com/liquidx/webviewscreensaver

### Ubuntu

https://github.com/lmartinking/webscreensaver

## Acknowledgements

This visualisation is implementing on the following APIs:

- **Bitcoin:** https://blockchain.info
- **Ethereum:** http://www.etherlisten.com/
- **Litecoin:** https://insight.litecore.io/
- **Nano:** https://www.nanode.co/
- **Prices:** https://www.cryptocompare.com/api/

Furthermore, it uses Google Webfonts and Material Icons.