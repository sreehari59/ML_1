// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Open Zeppelin:

// Open Zeppelin NFT guide:
// https://docs.openzeppelin.com/contracts/4.x/erc721

// Open Zeppelin ERC721 contract implements the ERC-721 interface and provides
// methods to mint a new NFT and to keep track of token ids.
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol

// Open Zeppelin ERC721URIStorage extends the standard ERC-721 with methods
// to hold additional metadata.
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// TODO:
// Other openzeppelin contracts might be useful. Check the Utils!
// https://docs.openzeppelin.com/contracts/4.x/utilities

// Local imports:

// TODO:
// You might need to adjust paths to import accordingly.

// Import BaseAssignment.sol
import "./BaseAssignment.sol";

// Import INFTMINTER.sol
import "./Interfaces/INFTMINTER.sol";

// You contract starts here:
// You need to inherit from multiple contracts/interfaces.
contract Assignment1 is INFTMINTER, ERC721URIStorage, BaseAssignment {
    using Counters for Counters.Counter;
    using Base64 for bytes;
    using Strings for uint256;

    // TODO:
    // Add the ipfs hash of an image that you uploaded to IPFS.
    string public IPFSHash = "QmVQ5x9r4zH3oFNFdqHRbBMXLGr7Bu3dcZrxCTkVagdA1h";
    // added "public" (?)

    // Total supply.
    uint256 public totalSupply;

    // Current price. See also: https://www.cryps.info/en/Gwei_to_ETH/1/
    uint256 private price = 0.001 ether;

    // TODO:
    // Add more state variables, as needed.

    Counters.Counter private _tokenIdTracker;
    bool private isSaleActive = true;

    // address payable public owner;

    // TODO:
    // Adjust the Token name and ticker as you like.
    // Very important! The validator address must be passed to the
    // BaseAssignment constructor (already inserted here).
    constructor()
        ERC721("AprilBreakToken", "ABT")
        BaseAssignment(0x80A2FBEC8E3a12931F68f1C1afedEf43aBAE8541)
    {
        // owner = payable(msg.sender);
    }

    // Mint a nft and send to _address.
    function mint(address _address) public payable returns (uint256) {
        // Your code here!

        // 1. First, check if the conditions for minting are met.

        require(_address != address(0), "ERC721: mint to the zero address");
        require(
            msg.value >= price,
            "Payment amount and the NFT price are not the same"
        );
        require(bytes(IPFSHash).length > 0, "IPFS hash is not set");
        require(isSaleActive, "Inactive sale");

        // 2. Then increment total supply and price.

        totalSupply += 1;
        price = price + 0.0001 ether;

        // 3. Get the current token id, after incrementing it.
        // Hint: Open Zeppelin has methods for this.

        _tokenIdTracker.increment();
        uint256 newTokenId = _tokenIdTracker.current();

        // 4. Mint the token.
        // Hint: Open Zeppelin has a method for this.

        _mint(_address, newTokenId);

        // 5. Compose the token URI with metadata info.
        // You might use the helper function getTokenURI.
        // Make sure to keep the data in "memory."
        // Hint: Learn about data locations.
        // https://dev.to/jamiescript/data-location-in-solidity-12di
        // https://solidity-by-example.org/data-locations/

        string memory tokenURI = getTokenURI(newTokenId, _address);

        // 6. Set encoded token URI to token.
        // Hint: Open Zeppelin has a method for this.

        _setTokenURI(newTokenId, tokenURI);

        // 7. Return the NFT id.

        return newTokenId;
    }

    // TODO:
    // Other methods of the INFTMINTER interface to be added here.
    // Hint: all methods of an interface are external, but here you might
    // need to adjust them to public.

    // Burn a nft.
    function burn(uint256 tokenId) public payable {
        require(_exists(tokenId), "NFT does not exist");
        require(
            ownerOf(tokenId) == msg.sender,
            "Caller is not the owner of this NFT"
        );

        totalSupply -= 1;
        price = price - 0.0001 ether;

        _burn(tokenId);
    }

    // Flip sale status.
    function flipSaleStatus() public {
        require(
            msg.sender == getOwner() || isValidator(msg.sender),
            "Only owner or validator can change sale status"
        );
        isSaleActive = !isSaleActive;
    }

    // Get sale status.
    function getSaleStatus() public view returns (bool) {
        return isSaleActive;
    }

    // Withdraw all funds to owner.
    function withdraw(uint256 amount) public {
        require(
            msg.sender == getOwner() || isValidator(msg.sender),
            "Only owner or validator can withdraw"
        );
        require(
            amount <= address(this).balance,
            "Not enough ether in the contract"
        );
        (bool sent, bytes memory data) = payable(msg.sender).call{
            value: amount
        }("");
        require(sent, "Failed to send Ether");
    }

    // Get current price.
    function getPrice() public view returns (uint256) {
        return price;
    }

    // Get total supply.
    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    // Get IPFS hash.
    function getIPFSHash() public view returns (string memory) {
        return IPFSHash;
    }

    // function isValidator(address _address) public view returns (bool) {
    //     return _address == address(0x80A2FBEC8E3a12931F68f1C1afedEf43aBAE8541);
    // }

    // function getOwner() public view returns (address) {
    //     return owner;
    // }

    /*=============================================
    =                   HELPER                  =
    =============================================*/

    // Get tokenURI for token id
    function getTokenURI(
        uint256 tokenId,
        address newOwner
    ) public view returns (string memory) {
        // Build dataURI.
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "My beautiful artwork #',
            tokenId.toString(),
            '"', // Name of NFT with id.
            '"hash": "',
            IPFSHash,
            '",', // Define hash of your artwork from IPFS.
            '"by": "',
            getOwner(),
            '",', // Address of creator.
            '"new_owner": "',
            newOwner,
            '"', // Address of new owner.
            "}"
        );

        // Encode dataURI using base64 and return it.
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    /*=====         End of HELPER         ======*/
}
