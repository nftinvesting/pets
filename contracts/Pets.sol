// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Pets is ERC721, Ownable {
	using SafeMath for uint256;
	using Strings for string;
	mapping(uint256 => uint256) private _totalSupply;

	IERC1155 public gutterCatNFTAddress;

	string public _baseURI =
		"https://raw.githubusercontent.com/nftinvesting/pets/master/other/default.json";

	string public _contractURI =
		"https://raw.githubusercontent.com/nftinvesting/guttercatgang_/master/contract_uri";
	mapping(uint256 => string) public _tokenURIs;

	constructor(address _catsNFTAddress) ERC721(_baseURI) {
		gutterCatNFTAddress = IERC1155(_catsNFTAddress);
	}

	function mint(uint256 _catID) external {
		//verify ownership
		require(
			gutterCatNFTAddress.balanceOf(msg.sender, _catID) > 0,
			"you have to own this cat with this id"
		);
		require(_totalSupply[_catID] == 0, "this pet is already owned by someone");

		//all good, mint it
		_totalSupply[_catID] = 1;
		_mint(msg.sender, _catID, 1, "0x0000");
	}

	function setBaseURI(string memory newuri) public onlyOwner {
		_baseURI = newuri;
	}

	function setContractURI(string memory newuri) public onlyOwner {
		_contractURI = newuri;
	}

	function uri(uint256 tokenId) public view override returns (string memory) {
		return string(abi.encodePacked(_baseURI, uint2str(tokenId)));
	}

	function contractURI() public view returns (string memory) {
		return _contractURI;
	}

	function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return "0";
		}
		uint256 j = _i;
		uint256 len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint256 k = len;
		while (_i != 0) {
			k = k - 1;
			uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
			bytes1 b1 = bytes1(temp);
			bstr[k] = b1;
			_i /= 10;
		}
		return string(bstr);
	}

	/**
	 * @dev Total amount of tokens in with a given id.
	 */
	function totalSupply(uint256 id) public view virtual returns (uint256) {
		return _totalSupply[id];
	}

	//see what's the current timestamp
	function currentTimestamp() public view returns (uint256) {
		return block.timestamp;
	}

	/**
	 * @dev Indicates weither any token exist with a given id, or not.
	 */
	function exists(uint256 id) public view virtual returns (bool) {
		return totalSupply(id) > 0;
	}

	// withdraw the earnings to pay for the artists & devs :)
	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

	// reclaim accidentally sent tokens
	function reclaimToken(IERC20 token) public onlyOwner {
		require(address(token) != address(0));
		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance);
	}
}
