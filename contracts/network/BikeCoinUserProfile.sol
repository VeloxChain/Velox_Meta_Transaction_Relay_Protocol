    pragma solidity 0.4.24;
import "./../token/ERC721/BikeOwnershipProtocol.sol";
import "./../token/ERC20/BKCTestToken.sol";

contract BikeCoinUserProfile is Ownable {
    using SafeMath for uint256;

    string ipfsHash;

    event Forwarded (address destination, uint value, bytes data, uint256 transferAmount, uint256 halfFeeAmount);
    event Received (address sender, uint value);
    event Rent(address indexed renter, address indexed bikeOwner, uint256 startTime, uint256 endTime, uint256 feeAmount);

    function () public payable { Received(msg.sender, msg.value); }

    function forward(address destination, uint value, bytes data) public onlyOwner {        
        require(executeCall(destination, value, data));             
    }

    // copied from GnosisSafe
    // https://github.com/gnosis/gnosis-safe-contracts/blob/master/contracts/GnosisSafe.sol
    function executeCall(address to, uint256 value, bytes data) internal returns (bool success) {
        assembly {
            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }  

    function setIPFSHash(string x) public onlyOwner {
	   ipfsHash = x;
	}

	function getIPFSHash() public view returns (string x) {
	   return ipfsHash;
	}

    function createBike(string ipfsHash, BikeOwnershipProtocol bikeProtocol) public {
        bikeProtocol.create(ipfsHash);
    }

    function startBikeRental(uint256 _tokenId, uint256 _startTime, BikeOwnershipProtocol bikeProtocol) public {
        bikeProtocol.rentStart(_tokenId,_startTime);
    }

    function endBikeRental(uint256 _tokenId, uint256 _endTime, BikeOwnershipProtocol bikeProtocol, BKCTestToken token) public {
        
        bikeProtocol.rentEnd(_tokenId,_endTime);

        address bikeOwner = bikeProtocol.ownerOf(_tokenId);

        uint256 startTime = bikeProtocol.getRentalStartTime(_tokenId);
        
        uint256 pricePerHour = bikeProtocol.getBikeRentalPrice(_tokenId);

        uint256 feeAmount = _endTime.sub(startTime).mul(pricePerHour).div(3600);

        //transfer rental fee
        token.transfer(bikeOwner,feeAmount);

        emit Rent(msg.sender, bikeOwner, startTime, _endTime, feeAmount);
    }
    

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    //Token receivable function
    function tokenFallback(address _from, uint _value, bytes _data) public pure {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        if (_data.length > 0)
        {
            uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
            tkn.sig = bytes4(u);
        }        

        //  * tkn variable is analogue of msg variable of Ether transaction
        //  * tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
        //  * tkn.value the number of tokens that were sent   (analogue of msg.value)
        //  * tkn.data is data of token transaction   (analogue of msg.data)
        //  * tkn.sig is 4 bytes signature of function if data of token transaction is a function execution
         
    }
}