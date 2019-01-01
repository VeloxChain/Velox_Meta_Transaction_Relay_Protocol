// require('dotenv').config();
// require('babel-register');
// require('babel-polyfill');

// const HDWalletProvider = require('truffle-hdwallet-provider');

// const providerWithMnemonic = (mnemonic, rpcEndpoint) =>
//   new HDWalletProvider(mnemonic, rpcEndpoint);

// const infuraProvider = network => providerWithMnemonic(
//   process.env.MNEMONIC || '',
//   `https://${network}.infura.io/${process.env.INFURA_API_KEY}`
// );

// const ropstenProvider = process.env.SOLIDITY_COVERAGE
//   ? undefined
//   : infuraProvider('ropsten');

// module.exports = {
//   networks: {
//     development: {
//       host: 'localhost',
//       port: 8545,
//       network_id: '*', // eslint-disable-line camelcase
//     },
//     ropsten: {
//       provider: ropstenProvider,
//       network_id: 3, // eslint-disable-line camelcase
//     },
//     coverage: {
//       host: 'localhost',
//       network_id: '*', // eslint-disable-line camelcase
//       port: 8555,
//       gas: 0xfffffffffff,
//       gasPrice: 0x01,
//     },
//     ganache: {
//       host: 'localhost',
//       port: 8545,
//       network_id: '*', // eslint-disable-line camelcase
//     },
//   },
// };

let HDWalletProvider = require("truffle-hdwallet-provider");
let mnemonic = "i don't know what it should be.... ";
//address will be: 0x2273066ac87d87ebd4cefd9f7b2c30152a474c5b
let provider = new HDWalletProvider(mnemonic, "http://testnet.bikecoin.network:8501")

// console.log(provider.wallet._privKey.toString("hex"))

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // for more about customizing your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            gas: 6000000,
            gasPrice: 4000000000,
            // from: "0x438cb5211D33684d2261877947E2E71913FB255E",
            network_id: "*" // Match any network id
        },
        coverage: {
            host: "127.0.0.1",
            network_id: "*",
            port: 8555,
            gas: 0xfffffffffff,
            gasPrice: 0x01
        },
        rinkeby: {
            provider: function () {
                return provider
            },
            network_id: 4,
            gas: 5800000,
            gasPrice: 4000000000,
        },
        ropsten: {
            provider: function () {
                return provider
            },
            network_id: 3,
            gas: 3800000,
            gasPrice: 4000000000,
        },

    },
    compilers: {
        solc: {
            version: "0.4.24", // ex:  "0.4.20". (Default: Truffle's installed solc)
        },
    }
}
