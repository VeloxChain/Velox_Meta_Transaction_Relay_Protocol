pragma solidity 0.4.24;

// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/token/ERC721/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

// File: contracts/token/ERC721/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: contracts/token/ERC721/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   *  after a `safetransfer`. This function MAY throw to revert and reject the
   *  transfer. This function MUST use 50,000 gas or less. Return of other
   *  than the magic value MUST result in the transaction being reverted.
   *  Note: the contract address is always the message sender.
   * @param _from The sending address
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}

// File: contracts/token/ERC721/ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
   * @dev Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existance of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * @dev The zero address indicates there is no approved address.
   * @dev There can only be one approved address per token at a given time.
   * @dev Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * @dev An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * @dev Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * @dev The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: contracts/token/ERC721/BikeOwnershipProtocol.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */

contract BikeOwnershipProtocol is ERC721, ERC721BasicToken {
	// Token name
	string internal name_;

	// Token symbol
	string internal symbol_;

	// Mapping from owner to list of owned token IDs
	mapping (address => uint256[]) internal ownedTokens;

	// Mapping from token ID to index of the owner tokens list
	mapping(uint256 => uint256) internal ownedTokensIndex;

	// Array with all token ids, used for enumeration
	uint256[] internal allTokens;

	// Mapping from token id to position in the allTokens array
	mapping(uint256 => uint256) internal allTokensIndex;

	// Optional mapping for token URIs
	mapping(uint256 => string) internal tokenURIs;

	//Ex-ower emails of a bike token
	mapping(uint256 => mapping(address => string)) public exOwnerEmails;

	//Ex-ower addresses
	mapping (uint256 => address[]) public exOwnerAddresses;

	//rental prices for bikes
	mapping (uint256 => uint256) public rentalPrices;

	//rental recorded time
	mapping (uint256 => uint256) public rentalStartTime;
	mapping (uint256 => uint256) public rentalEndTime;

	//rental owner
	mapping (uint256 => address) public renters;


	/**
	* @dev Constructor function
	*/
	function BikeOwnershipProtocol() public {
		name_ = "BikeOwnershipProtocol";
		symbol_ = "BKCOP";
	}

	/**
	* @dev Gets the token name
	* @return string representing the token name
	*/
	function name() public view returns (string) {
		return name_;
	}

	/**
	* @dev Gets the token symbol
	* @return string representing the token symbol
	*/
	function symbol() public view returns (string) {
		return symbol_;
	}


	/**
	* @dev Returns an URI for a given token ID
	* @dev Throws if the token ID does not exist. May return an empty string.
	* @param _tokenId uint256 ID of the token to query
	*/
	function tokenURI(uint256 _tokenId) public view returns (string) {
		require(exists(_tokenId));
		return tokenURIs[_tokenId];
	}

	/**
	* @dev Gets the token ID at a given index of the tokens list of the requested owner
	* @param _owner address owning the tokens list to be accessed
	* @param _index uint256 representing the index to be accessed of the requested tokens list
	* @return uint256 token ID at the given index of the tokens list owned by the requested address
	*/
	function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
		require(_index < balanceOf(_owner));
		return ownedTokens[_owner][_index];
	}

	/**
	* @dev Gets the total amount of tokens stored by the contract
	* @return uint256 representing the total amount of tokens
	*/
	function totalSupply() public view returns (uint256) {
		return allTokens.length;
	}

	/**
	* @dev Gets the token ID at a given index of all the tokens in this contract
	* @dev Reverts if the index is greater or equal to the total number of tokens
	* @param _index uint256 representing the index to be accessed of the tokens list
	* @return uint256 token ID at the given index of the tokens list
	*/
	function tokenByIndex(uint256 _index) public view returns (uint256) {
		require(_index < totalSupply());
		return allTokens[_index];
	}

	/**
	* @dev Internal function to set the token URI for a given token
	* @dev Reverts if the token ID does not exist
	* @param _tokenId uint256 ID of the token to set its URI
	* @param _uri string URI to assign
	*/
	function _setTokenURI(uint256 _tokenId, string _uri) internal {
		require(exists(_tokenId));
		tokenURIs[_tokenId] = _uri;
	}

	/**
	* @dev Internal function to add a token ID to the list of a given address
	* @param _to address representing the new owner of the given token ID
	* @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
	*/
	function addTokenTo(address _to, uint256 _tokenId) internal {
		super.addTokenTo(_to, _tokenId);
		uint256 length = ownedTokens[_to].length;
		ownedTokens[_to].push(_tokenId);
		ownedTokensIndex[_tokenId] = length;
	}

	/**
	* @dev Internal function to remove a token ID from the list of a given address
	* @param _from address representing the previous owner of the given token ID
	* @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
	*/
	function removeTokenFrom(address _from, uint256 _tokenId) internal {
		super.removeTokenFrom(_from, _tokenId);

		uint256 tokenIndex = ownedTokensIndex[_tokenId];
		uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
		uint256 lastToken = ownedTokens[_from][lastTokenIndex];

		ownedTokens[_from][tokenIndex] = lastToken;
		ownedTokens[_from][lastTokenIndex] = 0;
		// Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
		// be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
		// the lastToken to the first position, and then dropping the element placed in the last position of the list

		ownedTokens[_from].length--;
		ownedTokensIndex[_tokenId] = 0;
		ownedTokensIndex[lastToken] = tokenIndex;
	}

	/**
	* @dev Internal function to mint a new token
	* @dev Reverts if the given token ID already exists
	* @param _to address the beneficiary that will own the minted token
	* @param _tokenId uint256 ID of the token to be minted by the msg.sender
	*/
	function _mint(address _to, uint256 _tokenId) internal {
		super._mint(_to, _tokenId);

		allTokensIndex[_tokenId] = allTokens.length;
		allTokens.push(_tokenId);
		}

		/**
		* @dev Internal function to burn a specific token
		* @dev Reverts if the token does not exist
		* @param _owner owner of the token to burn
		* @param _tokenId uint256 ID of the token being burned by the msg.sender
		*/
		function _burn(address _owner, uint256 _tokenId) internal {
		super._burn(_owner, _tokenId);

		// Clear metadata (if any)
		if (bytes(tokenURIs[_tokenId]).length != 0) {
		  delete tokenURIs[_tokenId];
		}

		// Reorg all tokens array
		uint256 tokenIndex = allTokensIndex[_tokenId];
		uint256 lastTokenIndex = allTokens.length.sub(1);
		uint256 lastToken = allTokens[lastTokenIndex];

		allTokens[tokenIndex] = lastToken;
		allTokens[lastTokenIndex] = 0;

		allTokens.length--;
		allTokensIndex[_tokenId] = 0;
		allTokensIndex[lastToken] = tokenIndex;
	}

	function create(string ipfsHash) public {
	  uint256 tokenId = allTokens.length + 1;
	  _mint(msg.sender, tokenId);

	  _setTokenURI(tokenId, ipfsHash);	
	}

	function setTokenIPFSHash(uint256 _tokenId, string _ipfsHash) public {
		_setTokenURI(_tokenId,_ipfsHash);
	}

	function verifyByExOwner(uint256 tokenId, address exOwner, string email) public {
		require(bytes(exOwnerEmails[tokenId][exOwner]).length == 0);
		
		exOwnerAddresses[tokenId].push(exOwner);
		exOwnerEmails[tokenId][exOwner] = email;
	}

	function getExOwnerAddresses(uint256 tokenId) public returns (address[]){
		return exOwnerAddresses[tokenId];
	}

	function getExOwnerEmail(uint256 tokenId, address exOwner) public returns (string){
		return exOwnerEmails[tokenId][exOwner];
	}

	function setBikeRentalPrice(uint256 _tokenId, uint256 _price) public{
		require(ownerOf(_tokenId) == msg.sender);
		rentalPrices[_tokenId] = _price;
	}

	function getBikeRentalPrice(uint256 _tokenId) public view returns (uint256) {
		return rentalPrices[_tokenId];
	}

	function rentStart(uint256 _tokenId, uint256 _startTime) public {
		require(ownerOf(_tokenId) != msg.sender);

		rentalStartTime[_tokenId] = _startTime;
		renters[_tokenId] = msg.sender;
	}

	function rentEnd(uint256 _tokenId, uint256 _endTime) public{
		require(renters[_tokenId] == msg.sender);
		require(rentalStartTime[_tokenId] != 0x0);	

		uint256 startTime = rentalStartTime[_tokenId];
		require(_endTime > startTime);

		rentalEndTime[_tokenId] = _endTime;
		renters[_tokenId] = 0x0;
	}

	function getRentalStartTime(uint _tokenId) public returns (uint256) {
		return rentalStartTime[_tokenId];
	}

	function getRenterOfBike(uint _tokenId) public returns (address) {
		return renters[_tokenId];
	}

}

// File: contracts/token/ERC20/BKCTestToken.sol

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}



// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract BKCTestToken is ERC20Interface, Ownable {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "BKCMVPTestToken";
        name = "BC Network Test Token";
        decimals = 18;
        _totalSupply = 1000000000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

// File: contracts/network/BikeCoinUserProfile.sol

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

// File: contracts/network/BikeCoinNetwork.sol

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
