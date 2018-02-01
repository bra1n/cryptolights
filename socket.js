const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: process.env.PORT || 3000 });

// Broadcast to all.
wss.broadcast = data => {
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(data);
    }
  });
};

wss.on('connection', function connection(ws) {
  console.log('client connected', wss.clients.size);
  ws.on('close', () => console.log('client disconnected', wss.clients.size));
});

const etherSocket = new WebSocket('ws://listen.etherlisten.com:8546');

etherSocket.on('open', () => {
  etherSocket.send(JSON.stringify({"id": 1, "method": "eth_newBlockFilter", "params": [], "jsonrpc":"2.0"}));
  etherSocket.send(JSON.stringify({"id": 4, "method": "eth_newPendingTransactionFilter", "params": [], "jsonrpc":"2.0"}));
});

let blockFilterId, txFilterId;
let i = 0;
etherSocket.on('message', (data) => {
  data = JSON.parse(data);
  i = 7 + (i++) % 30000;
  switch(data.id) {
    // block filter handling
    case 1: // eth_newBlockFilter -> parity_subscribe
      blockFilterId = data.result;
      etherSocket.send(JSON.stringify({"id": 2, "method": "parity_subscribe", "params": ["eth_getFilterChanges", [blockFilterId]], "jsonrpc":"2.0"}));
      break;
    case 2: // parity_subscribe blockFilterId -> eth_getFilterChanges
      setInterval(() => {
        etherSocket.send(JSON.stringify({"id": 3, "method": "eth_getFilterChanges", "params": [blockFilterId], "jsonrpc":"2.0"}));
      }, 500);
      break;
    case 3: // eth_getFilterChanges blockFilterId -> eth_getBlockByHash
      if (data.result.length) {
        etherSocket.send(JSON.stringify({"id": i, "method": "eth_getBlockByHash", "params": [data.result[0], false], "jsonrpc":"2.0"}));
      }
      break;

    // transaction filter handling
    case 4: // eth_newPendingTransactionFilter -> parity_subscribe
      txFilterId = data.result;
      etherSocket.send(JSON.stringify({"id": 5, "method": "parity_subscribe", "params": ["eth_getFilterChanges", [txFilterId]], "jsonrpc":"2.0"}));
      break;
    case 5: // parity_subscribe txFilterId -> eth_getFilterChanges
      setInterval(() => {
        etherSocket.send(JSON.stringify({"id": 6, "method": "eth_getFilterChanges", "params": [txFilterId], "jsonrpc":"2.0"}));
      }, 500);
      break;
    case 6: // eth_getFilterChanges txFilterId -> eth_getTransactionByHash
      for (let hash_i in data.result) {
        const txHash = data.result[hash_i];
        etherSocket.send(JSON.stringify({"id": i, "method": "eth_getTransactionByHash", "params": [txHash], "jsonrpc":"2.0"}));
      }
      break;

    // actual data
    default:
      if (data.result && !data.result.input) {
        // block received
        let blockHeight = parseInt(data.result.number);
        let transactions = data.result.transactions.length;
        let volumeSent = parseInt(data.result.gasUsed);
        let blockSize = parseInt(data.result.size);
        // console.log('Block', blockHeight, transactions, volumeSent, blockSize);
        wss.broadcast(JSON.stringify({type: 'block', blockHeight, transactions, volumeSent, blockSize}));
      } else if (data.result && data.result.input) {
        // transaction received
        const transaction = data.result;
        const transacted = parseInt(transaction.value);
        const to = transaction.to;
        const ethers = transacted / 1000000000000000000;
        const hash = transaction.hash;
        const isContract = transaction.input !== '0x';
        const gas = parseInt(transaction.gas);
        const gasPrice = parseInt(transaction.gasPrice);
        const fee = gas * gasPrice / 1000000000000000000;
        // console.log('Transaction', ethers, hash, to, isContract, fee);
        wss.broadcast(JSON.stringify({type: 'tx', ethers, hash, to, isContract, fee}));
      }
  }
});
