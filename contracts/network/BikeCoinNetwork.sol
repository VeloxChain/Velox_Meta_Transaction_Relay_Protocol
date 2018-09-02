pragma solidity 0.4.24;
import "./../ownership/Ownable.sol";
import "./../math/SafeMath.sol";
import "./BikeCoinUserProfile.sol";


contract BikeCoinNetwork is Ownable {
	using SafeMath for uint256;
    address relay;
    mapping(address => address) owners;
    uint256 numberOfProfiles = 0;
    mapping(address => bool) whitelist;

    modifier onlyAuthorized() {
        require((msg.sender == relay) || checkMessageData(msg.sender));
        _;
    }

    modifier onlyOwnerOfProfile(address profile, address sender) {
        require(isOwnerOfProfile(profile, sender));
        _;
    }

  
    modifier validAddress(address addr) { //protects against some weird attacks
        require(addr != address(0));
        _;
    }
    modifier validDestination(address destination) {
        require(whitelist[destination] == true);
        _;
    }

    function BikeCoinNetwork(address _relayAddress) public {
        relay = _relayAddress;
    }

    function createUserProfile(address owner, string ipfsMetaData) public 
        validAddress(owner) 
        onlyAuthorized
    {
        require (owners[owner] == address(0));
        require (bytes(ipfsMetaData).length > 0);
        
        BikeCoinUserProfile userProfile = new BikeCoinUserProfile();
        userProfile.setIPFSHash(ipfsMetaData);
        owners[owner] = userProfile;        
        numberOfProfiles = numberOfProfiles.add(1);
    }

    function getUserProfile(address owner) public view returns (address) {
        return owners[owner];
    }

    function updateUserProfileMetaData(address sender, BikeCoinUserProfile profile, string ipfsHash) public
        onlyAuthorized
        onlyOwnerOfProfile(profile, sender) {
        profile.setIPFSHash(ipfsHash);
    }

    function addBikeToNetwork(address sender, string _ipfsMetaData, BikeCoinUserProfile profile, BikeOwnershipProtocol bikeProtocol) 
        onlyAuthorized
        onlyOwnerOfProfile(profile, sender)
    {
        profile.createBike(_ipfsMetaData,bikeProtocol);
    }

    function startBikeRental(address sender, uint256 _tokenId, uint256 _startTime, BikeCoinUserProfile profile,  BikeOwnershipProtocol bikeProtocol) public
        onlyAuthorized
        onlyOwnerOfProfile(profile, sender) 
    {
        profile.startBikeRental(_tokenId,_startTime,bikeProtocol);
    }

    function endBikeRental(address sender , uint256 _tokenId, uint256 _endTime, BikeCoinUserProfile profile, BikeOwnershipProtocol bikeProtocol, BKCTestToken token) public 
        onlyAuthorized
        onlyOwnerOfProfile(profile, sender) 
    {
        profile.endBikeRental(_tokenId, _endTime ,bikeProtocol, token);
    }

     /// @dev Allows a user to forward a call through their proxy.
    function forwardTo(address sender, BikeCoinUserProfile profile, address destination, uint value, bytes data) public
        onlyAuthorized
        onlyOwnerOfProfile(profile, sender) 
        validDestination(destination)
    {
        profile.forward(destination, value, data);
    }   

    function addToWhitelist(address[] contractAddresses) 
    onlyOwner
    {
        updateWhitelist(contractAddresses,true);
    }

    function removeFromWhitelist(address[] contractAddresses)
    onlyOwner
    {
        updateWhitelist(contractAddresses,false);
    }
    function updateWhitelist(address[] contractAddresses, bool newStatus) private {
        for (uint i = 0; i < contractAddresses.length; i++) {
            whitelist[contractAddresses[i]] = newStatus;
        }
    }

    //Checks that address a is the first input in msg.data.
    //Has very minimal gas overhead.
    function checkMessageData(address a) internal pure returns (bool t) {
        if (msg.data.length < 36) return false;
        assembly {
            let mask := 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            t := eq(a, and(mask, calldataload(4)))
        }
    }

    function isOwnerOfProfile(address profile, address owner) public view returns (bool) {
        return (owners[owner] == profile);
    }
}