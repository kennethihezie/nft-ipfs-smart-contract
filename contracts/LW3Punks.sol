// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract LW3Punks is ERC721Enumerable, Ownable {
    using Strings for uint256;

    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;

    // _providerPrefix is the prefix for the metadata provider. Eg: https://gateway.pinata.cloud/ipfs/
    string _providerPrefix;

    //  _price is the price of one LW3Punks NFT
    uint256 public _price;

    // _paused is used to pause the contract in case of an emergency
    bool public _paused;

    // max number of LW3Punks
    uint256 public _maxTokenIds;

    // total number of tokenIds minted
    uint256 public _tokenIds;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    modifier tokenUrlNotEmpty() {
        require(bytes(_baseURI()).length > 0, "Value must be set to a non-empty string");
        _;
    }

    modifier canMint() {
        require(_tokenIds < _maxTokenIds, "Exceed maximum LW3Punks supply");
        require(msg.value >= _price, "Ether sent is not correct");
        _;
    }

    modifier tokenIdExists(uint256 tokenId) {
        require(ownerOf(tokenId) != address(0), "URI query for nonexistent token");
        _;
    }

    /**
     * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
     * name in our case is `LW3Punks` and symbol is `LW3P`.
     * Constructor for LW3P takes in the baseURI to set _baseTokenURI for the collection.
     */
    constructor(
        string memory providerPrefix,
        string memory baseURI,
        uint256 price,
        uint256 maxTokenIds
    ) ERC721("LW3Punks", "LW3P") Ownable(msg.sender) {
        _providerPrefix = providerPrefix;
        _baseTokenURI = baseURI;
        _price = price;
        _maxTokenIds = maxTokenIds;
    }

    /**
     * @dev mint allows an user to mint 1 NFT per transaction.
     */
    function mint() public payable onlyWhenNotPaused canMint {
        _tokenIds += 1;
        _safeMint(msg.sender, _tokenIds);
    }

    /**
     * @dev _baseURI overrides the Openzeppelin's ERC721 implementation which by default
     * returned an empty string for the baseURI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return string(abi.encodePacked(_providerPrefix, _baseTokenURI));
    }

    /**
     * @dev tokenURI overrides the Openzeppelin's ERC721 implementation for tokenURI function
     * This function returns the URI from where we can extract the metadata for a given tokenId
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override tokenIdExists(tokenId) tokenUrlNotEmpty returns (string memory) {
        string memory baseURI = _baseURI();

        // EG: https://gateway.pinata.cloud/ipfs/Qmbygo38DWF1V8GttM1zy89KzyZTPU2FLUzQtiDvB7q6i5/1.json

        return string(abi.encodePacked(baseURI, "/", tokenId.toString(), ".json"));
    }

    function updatePrice(uint256 price) public onlyOwner {
        _price = price;
    }

    function changeProviderPrefix(string memory providerPrefix) public onlyOwner {
        _providerPrefix = providerPrefix;
    }

     /**
     * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool value) public onlyOwner {
        _paused = value;
    }

    /**
     * @dev withdraw sends all the ether in the contract
     * to the owner of the contract
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
