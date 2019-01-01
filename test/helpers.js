const CryptoJS = require('crypto-js')
const coder = require('web3/lib/solidity/coder')
const leftPad = require('left-pad')
const solsha3 = require('solidity-sha3').default
const utils = require("ethereumjs-util")
const BigNumber = require('bignumber.js')
const Transaction = require("ethereumjs-tx")
const { generateMnemonic, EthHdWallet } = require('eth-hd-wallet')

const hdWallet = EthHdWallet.fromMnemonic("frost mimic deer annual build develop discover split rose gather ahead gloom")

console.log(hdWallet.generateAddresses(2))


const  wallet  = hdWallet._children[0].wallet
const wallet1  = hdWallet._children[1].wallet


var exports = module.exports = {
	wallet: wallet,
  wallet1: wallet1
}

const pad = (n) => {
  assert.equal(typeof (n), 'string', "Passed in a non string")
  let data
  if (n.startsWith("0x")) {
    data = '0x' + leftPad(n.slice(2), '64', '0')
    assert.equal(data.length, 66, "packed incorrectly")
    return data;
  } else {
    data = '0x' + leftPad(n, '64', '0')
    assert.equal(data.length, 66, "packed incorrectly")
    return data;
  }
}

exports.encodeFunctionTxData = (functionName, types, args) => {
  var fullName = functionName + '(' + types.join() + ')';
  var signature = CryptoJS.SHA3(fullName, { outputLength: 256 }).toString(CryptoJS.enc.Hex).slice(0, 8);
  var dataHex = '0x' + signature + coder.encodeParams(types, args);
  return dataHex;
}

exports.signPayload = async (signingAddr, txRelay, whitelistOwner, destinationAddress, functionName, functionTypes, functionParams, privateKey) => {
  if (functionTypes.length !== functionParams.length) {
    return //should throw error
  }
  if (typeof (functionName) !== 'string') {
    return //should throw error
  }
  let nonce
  let blockTimeout
  let data
  let hashInput
  let hash
  let sig
  let retVal = {}

  data = exports.encodeFunctionTxData(functionName, functionTypes, functionParams)
  nonce = await txRelay.getNonce.call(signingAddr)
  //Tight packing, as Solidity sha3 does
  hashInput = '0x1900' + txRelay.address.slice(2) + whitelistOwner.slice(2) + pad(nonce.toString('hex')).slice(2)
    + destinationAddress.slice(2) + data.slice(2)

  hash = solsha3(hashInput)
  sig = utils.ecsign(new Buffer(utils.stripHexPrefix(hash), 'hex'), privateKey);
  // sig = lightwallet.signing.signMsgHash(lw, keyFromPw, hash, signingAddr)
  retVal.r = '0x' + sig.r.toString('hex')
  retVal.s = '0x' + sig.s.toString('hex')
  retVal.v = sig.v //Q: Why is this not converted to hex?
  retVal.data = data
  retVal.hash = hash
  retVal.nonce = nonce
  retVal.dest = destinationAddress

  return retVal
}

exports.transferERC223Token = async (from,to, amount, privateKey, bikeCoinContract) => {
  console.log("transferERC223Token from: "+ from + "to: "+ to)

  //ensure have enough ETH to send ERC223 token
  await web3.eth.sendTransaction({ from: web3.eth.coinbase, to: from, value: web3.toWei(0.1, "ether") })

  let txData = await bikeCoinContract.transfer.getData(to, new BigNumber(amount), { from: from })

  const nonce = web3.eth.getTransactionCount(from)

  const txParams = {
    from: from,
    to: bikeCoinContract.address,
    value: 0,
    nonce: nonce,
    gasPrice: 1000000000,
    gasLimit: 2100000,
    data: txData,
    chainId: 5777 /* see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-155.md */
  }

  const tx = new Transaction(txParams)

  tx.sign(privateKey)

  var raw = '0x' + tx.serialize().toString('hex');

  let txHash = await web3.eth.sendRawTransaction(raw)
}

exports.toERC20COIN = (amount) => {
	return (Math.pow(10,18)*amount);
}
exports.fromERC20COIN = (amount) => {
	return amount/Math.pow(10,18);	
}
exports.stringToHex = (str) => {
    var hex, i;

    var result = "";
    for (i=0; i<this.length; i++) {
        hex = this.charCodeAt(i).toString(16);
        result += ("000"+hex).slice(-4);
    }

    return result
}