// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "erc721a/contracts/ERC721A.sol";

pragma solidity ^0.8.9;

contract Fish is ERC721A, Pausable, Ownable, ReentrancyGuard {
	using Strings for uint256;

	uint64 public maxSupply = 3000;
	uint64 private mintPrice = 1 ether;
	uint64 private constant maxAirdropAmount = 100;

	uint64 private maxMintsPerAddress = 20;

	bool private airdrop;

	string private baseURI = "";

	mapping(address => uint256) public MintsCount;

	event NewURI(string newURI, address updatedBy);
	event WithdrawnPayment(uint256 ownerBalance, address owner);
	event updateGiveAwayAddress(address giveAwayAddress, address updatedBy);
	event updateMaxSupply(uint256 newMaxSupply, address updatedBy);
	event updateMaxMintsPerAddress(uint256 newMaxMintsPerAddress, address updatedBy);
	event updateMintPrice(uint256 MintPricePhase03TypeAll, address updatedBy);

	constructor() ERC721A("Fishy Collection", "FI$H") {}

	/**
	 * @dev setMaxSupply updates maxSupply
	 *
	 * Emits a {updateMaxSupply} event.
	 *
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 */
	function setMaxSupply(uint64 newMaxSupply) external onlyOwner {
		require(newMaxSupply > totalSupply(), "Invalid max supply");
		maxSupply = newMaxSupply;
		emit updateMaxSupply(newMaxSupply, msg.sender);
	}

	/**
	 * @dev setMaxMintsPerAddress updates maxMintsPerAddress
	 *
	 * Emits a {updateMaxMintsPerAddress} event.
	 *
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 */
	function setMaxMintsPerAddress(uint8 max) external onlyOwner {
		maxMintsPerAddress = max;
		emit updateMaxMintsPerAddress(max, msg.sender);
	}

	/**
	 * @dev setMintPricePhase03TypeAll updates mintPrice
	 *
	 * Emits a {updateMintPrice} event.
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 */
	function setMintPrice(uint8 max) external onlyOwner {
		mintPrice = max;
		emit updateMintPrice(max, msg.sender);
	}

	/**
	 * @dev setBaseUri updates the new token URI in contract.
	 *
	 * Emits a {NewURI} event.
	 *
	 * Requirements:
	 *
	 * - Only owner of contract can call this function
	 **/

	function setBaseUri(string memory uri) external onlyOwner {
		baseURI = uri;
		emit NewURI(uri, msg.sender);
	}

	/**
	 * @dev Mint to mint nft
	 *
	 * Emits [Transfer] event.
	 *
	 **/

	function mint(uint64 amount) external payable whenNotPaused nonReentrant {
		_checkMint(amount, maxMintsPerAddress, mintPrice);

		// increment mint count
		unchecked {
			MintsCount[msg.sender] = MintsCount[msg.sender] + amount;
		}

		// mint
		_mint(msg.sender, amount);
	}

	function _checkMint(
		uint64 amount,
		uint64 maxMint,
		uint64 price
	) internal {
		require(amount < maxMint + 1, "Invalid amount");
		require(msg.value > amount * price - 1, "Insufficient funds in the wallet");
		require(
			MintsCount[msg.sender] + amount < maxMint + 1,
			"Maximum amount per wallet already minted for this phase"
		);
		require(totalSupply() + amount < maxSupply + 1, "Max supply reached");
	}

	/**
	 * @dev giveAway mints 100 NFT once.
	 *
	 * Emits a {Transfer} event.
	 *
	 * Requirements:
	 *
	 * - Only the giveAwayAddress call this function
	 */

	function giveAway() external onlyOwner {
		require(!airdrop, "Airdrop already performed.");
		uint256 _tokenId = _nextTokenId();
		require(_tokenId + maxAirdropAmount < maxSupply + 1, "Max supply limit reached");
		_mint(msg.sender, maxAirdropAmount);
		airdrop = true;
	}

	/**
	 * @dev getMintsCount returns count mints by address
	 *
	 */
	function getMintsCount(address _address) public view returns (uint256) {
		return MintsCount[_address];
	}

	/**
	 * @dev getbaseURI returns the base uri
	 *
	 */

	function getbaseURI() public view returns (string memory) {
		return baseURI;
	}

	/**
	 * @dev tokenURI returns the uri to meta data
	 *
	 */

	function tokenURI(uint256 tokenId) public view override returns (string memory) {
		require(_exists(tokenId), "FI$H: Query for non-existent token");
		return
			bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
	}

	/// @dev Returns the starting token ID.
	function _startTokenId() internal view virtual override returns (uint256) {
		return 1;
	}

	/**
	 * @dev pause() is used to pause contract.
	 *
	 * Emits a {Paused} event.
	 *
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 **/

	function pause() public onlyOwner whenNotPaused {
		_pause();
	}

	/**
	 * @dev unpause() is used to unpause contract.
	 *
	 * Emits a {Unpaused} event.
	 *
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 **/

	function unpause() public onlyOwner whenPaused {
		_unpause();
	}

	/**
	 * @dev withdraw is used to withdraw payment from contract.
	 *
	 * Emits a {WithdrawnPayment} event.
	 *
	 * Requirements:
	 *
	 * - Only the owner can call this function
	 **/

	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		address owner = owner();
		(bool success, ) = payable(owner).call{value: balance}("");
		require(success, "Failed Transfer funds to owner");
		emit WithdrawnPayment(balance, owner);
	}
}
