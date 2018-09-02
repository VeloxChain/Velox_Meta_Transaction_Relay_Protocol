const TxRelay = artifacts.require("./TxRelay.sol")
const BikeCoinUserProfile = artifacts.require("./BikeCoinUserProfile.sol")
const BikeCoinNetwork = artifacts.require("./BikeCoinNetwork.sol")
const BikeOwnershipProtocol = artifacts.require("./BikeOwnershipProtocol.sol")
const BKCTestToken = artifacts.require("./BKCTestToken.sol")

const helper = require('./helpers')

const wallet = helper.wallet

let ethFounderBalance = 0
let txRelayContract
let bikeCoinNetworkContract

let zeroAddress = "0x0000000000000000000000000000000000000000"

let user1 = "0x55129eb82651dce3ccde25f5bf4ae9680db62c4e"


contract('Relay transaction', function (accounts) {

  before("setup ", async function () {    

  });

  beforeEach(async function () {
    // this.token = await ERC721Token.new(name, symbol, { from: creator });
  });

  it("test ", async () => {
    const signer = "0x980063874bBF3C211d6c814571636184C8721f1f"
    txRelayContract = await TxRelay.new()
    console.log("txRelayContract "+ txRelayContract.address)
    // console.log("coinbase "+ web3.eth.coinbase)

    bikeCoinNetworkContract = await BikeCoinNetwork.new(txRelayContract.address)
    console.log("bikeCoinNetworkContract " + bikeCoinNetworkContract.address)

    let bikeToken = await BikeOwnershipProtocol.new()
    console.log("bikeToken " + bikeToken.address)

    let types = ['address','string']
    let params = [signer,'zdpuAoeFPoyCp4hU6jb9aNgrz2GpHcBZRzm8gfGMkBb3Z5n15']

    p = await helper.signPayload(signer, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'createUserProfile', types, params,wallet.getPrivateKey())

    let tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)
    let profile1 = await bikeCoinNetworkContract.getUserProfile.call(signer)
    console.log("profile 1: ", profile1)


    let signer2 = "0x"+helper.wallet1.getAddress().toString("hex")

    types = ['address','string']
    params = [signer2,'zdpuAoeFPoyCp4hU6jb9aNgrz2GpHcBZRzm8gfGMkBb3Z5n15']

    p = await helper.signPayload(signer2, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'createUserProfile', types, params,helper.wallet1.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)
    let profile2 = await bikeCoinNetworkContract.getUserProfile.call(signer2)
    console.log("profile 2: ", profile2)



    // await bikeCoinNetworkContract.createUserProfile(accounts[1],"zdpuAoeFPoyCp4hU6jb9aNgrz2GpHcBZRzm8gfGMkBb3Z5n15")
    // let profile1 = bikeCoinNetworkContract.getUserProfile(accounts[1])


    types = ["address","string","address", "address"];
    params = [signer,"zdpuAoeFPoyCp4hU6jb9aNgrz2GpHcBZRzm8gfGMkBb3Z5n15", profile1, bikeToken.address];

    p = await helper.signPayload(signer, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'addBikeToNetwork', types, params,wallet.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    let bikeTokens = await bikeToken.balanceOf(profile1)
    for (var i = bikeTokens.length - 1; i >= 0; i--) {
      let tknId = await bikeToken.tokenOfOwnerByIndex(profile1,i);
      // console.log(tknId)
    }

    ///transfer ownership of ERC721
    await bikeCoinNetworkContract.addToWhitelist([bikeToken.address])
    let transferOwnershipData = helper.encodeFunctionTxData('transferFrom', ['address','address','uint256'], [profile1,profile2,1])
    
    types = ["address","address","address", "uint256","bytes"];
    params = [signer,profile1, bikeToken.address, 0, transferOwnershipData];

    p = await helper.signPayload(signer, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'forwardTo', types, params,wallet.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    //rent bike
    let userProfile2 = await BikeCoinUserProfile.at(profile2)
    let testToken = await BKCTestToken.new({from:accounts[0]})
    console.log(testToken.address)
    let blanceOfProfile2 = await testToken.balanceOf(profile2)

    console.log(blanceOfProfile2.toNumber() + "BKC")
    await testToken.transfer(profile2,helper.toERC20COIN(2000))
    await testToken.transfer(profile1,helper.toERC20COIN(2000))

    blanceOfProfile2 = await testToken.balanceOf(profile2)
    console.log(helper.fromERC20COIN(blanceOfProfile2.toNumber()) + "BKC")

    let now = new Date();
    let seconds = Math.round(now.getTime()/1000);

    console.log(seconds)

    //set price

    let setBikeRentalPriceData = helper.encodeFunctionTxData('setBikeRentalPrice', ['uint256','uint256'], [1,helper.toERC20COIN(301)])
    
    types = ["address","address","address", "uint256","bytes"];
    params = [signer2,profile2, bikeToken.address, 0, setBikeRentalPriceData];

    p = await helper.signPayload(signer2, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'forwardTo', types, params, helper.wallet1.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    let rentalPrice = await bikeToken.getBikeRentalPrice(1)
    console.log("rentalPrice: " + helper.fromERC20COIN(rentalPrice.toNumber()) + " per Hour")

    setBikeRentalPriceData = helper.encodeFunctionTxData('setBikeRentalPrice', ['uint256','uint256'], [1,helper.toERC20COIN(0)])
    
    types = ["address","address","address", "uint256","bytes"];
    params = [signer2,profile2, bikeToken.address, 0, setBikeRentalPriceData];

    p = await helper.signPayload(signer2, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'forwardTo', types, params, helper.wallet1.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    rentalPrice = await bikeToken.getBikeRentalPrice(1)
    console.log("rentalPrice: " + helper.fromERC20COIN(rentalPrice.toNumber()) + " per Hour")

    setBikeRentalPriceData = helper.encodeFunctionTxData('setBikeRentalPrice', ['uint256','uint256'], [1,helper.toERC20COIN(300)])
    
    types = ["address","address","address", "uint256","bytes"];
    params = [signer2,profile2, bikeToken.address, 0, setBikeRentalPriceData];

    p = await helper.signPayload(signer2, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'forwardTo', types, params, helper.wallet1.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    rentalPrice = await bikeToken.getBikeRentalPrice(1)
    console.log("rentalPrice: " + helper.fromERC20COIN(rentalPrice.toNumber()) + " per Hour")


    // startBikeRental(address sender, uint256 _tokenId, uint256 _startTime, BikeCoinUserProfile profile,  BikeOwnershipProtocol bikeProtocol) 
    types = ["address","uint256","uint256", "address","address"];
    params = [signer,1,seconds, profile1, bikeToken.address];


    p = await helper.signPayload(signer, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'startBikeRental', types, params,wallet.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    //function endBikeRental(address sender , uint256 _tokenId, uint256 _endTime, BikeCoinUserProfile profile, BikeOwnershipProtocol bikeProtocol, BKCTestToken token) public {
    types = ["address","uint256","uint256", "address","address","address"];
    params = [signer,1,seconds+(4.5*3600), profile1, bikeToken.address, testToken.address];


    p = await helper.signPayload(signer, txRelayContract, zeroAddress, bikeCoinNetworkContract.address,
      'endBikeRental', types, params,wallet.getPrivateKey())

    tx = await txRelayContract.relayMetaTx(p.v, p.r, p.s, p.dest, p.data, 0)

    blanceOfProfile2 = await testToken.balanceOf(profile2)
    console.log(helper.fromERC20COIN(blanceOfProfile2.toNumber()) + "BKC")
  }) 
});