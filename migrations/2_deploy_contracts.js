// var NANJCOIN = artifacts.require("./NANJCOIN.sol");
const TxRelay = artifacts.require('./TxRelay.sol')
var BikeCoinNetwork = artifacts.require("./BikeCoinNetwork.sol");
var BikeOwnershipProtocol = artifacts.require("./BikeOwnershipProtocol.sol");

module.exports = function(deployer) {
  deployer.deploy(TxRelay).then(() => {
    return deployer.deploy(BikeCoinNetwork,TxRelay.address)
  })
  deployer.deploy(BikeOwnershipProtocol)
   
};
