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
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";

// TODO:
// Other openzeppelin contracts might be useful. Check the Utils!
// https://docs.openzeppelin.com/contracts/4.x/utilities

// Local imports:

// TODO:
// You might need to adjust paths to import accordingly.

import "./BaseAssignment.sol";

// Import INFTMINTER.sol
import "./Interfaces/INFTMINTER.sol";

// You contract starts here:
// You need to inherit from multiple contracts/interfaces.
contract Assignment1old is INFTMINTER, ERC721URIStorage, BaseAssignment {
    // TODO:
    // Add the ipfs hash of an image that you uploaded to IPFS.
    string IPFSHash =
        "https://ipfs.io/ipfs/QmTq6GPCpCgncicKpUBhXCj99vKczBjFe88ogiCJmpoWPs";

    // Total supply.
    uint256 public totalSupply;

    // Current price. See also: https://www.cryps.info/en/Gwei_to_ETH/1/
    uint256 private price = 0.001 ether;

    // TODO:
    // Add more state variables, as needed.
    uint256 public currentTokenId;
    bool public state;
    address public owner;

    // TODO:
    // Adjust the Token name and ticker as you like.
    // Very important! The validator address must be passed to the
    // BaseAssignment constructor (already inserted here).
    constructor()
        ERC721("Token", "TUSH")
        BaseAssignment(0x80A2FBEC8E3a12931F68f1C1afedEf43aBAE8541)
    {
        totalSupply = 0;
        currentTokenId = 0;
        state = true;
        owner = msg.sender;
    }

    // Mint a nft and send to _address.
    function mint(address _address) public payable returns (uint256) {
        // Your code here!
        // 1. First, check if the conditions for minting are met.
        require(state, "The sale is not active, You can not mint the token");
        require(
            msg.value >= getPrice(),
            "Please send enough amount of ether to mint the token"
        );
        // 2. Then increment total supply and price.
        totalSupply++;
        // 3. Get the current token id, after incrementing it.
        currentTokenId++;
        // Hint: Open Zeppelin has methods for this.
        // 4. Mint the token.
        _safeMint(_address, currentTokenId);
        // Hint: Open Zeppelin has a method for this.
        // 5. Compose the token URI with metadata info.
        // You might use the helper function getTokenURI.
        string memory tokenURI = getTokenURI(currentTokenId, _address);
        // Make sure to keep the data in "memory."
        // Hint: Learn about data locations.
        // https://dev.to/jamiescript/data-location-in-solidity-12di
        // https://solidity-by-example.org/data-locations/
        // 6. Set encoded token URI to token.
        _setTokenURI(currentTokenId, tokenURI);
        // Hint: Open Zeppelin has a method for this.
        // 7. Return the NFT id.
        return currentTokenId;
    }

    // TODO:
    // Other methods of the INFTMINTER interface to be added here.
    // Hint: all methods of an interface are external, but here you might
    // need to adjust them to public.
    function getIPFSHash() public view returns (string memory) {
        return IPFSHash;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function flipSaleStatus() public {
        require(
            msg.sender == owner || isValidator(msg.sender),
            "Only the owner or the validator can change the state"
        );
        state = !state;
    }

    function getSaleStatus() public view returns (bool) {
        return state;
    }

    function withdraw(uint256 amount) public {
        require(
            msg.sender == owner || isValidator(msg.sender),
            "Only the owner or the validator can withdraw the funds"
        );
        uint256 balance = address(this).balance;
        require(balance > amount, "Insufficient balance");
        (bool sent, bytes memory data) = payable(msg.sender).call{
            value: amount
        }("");
        require(sent, "Failed to Withdraw");
    }

    function getPrice() public view returns (uint256) {
        return 0.001 ether + (totalSupply * 0.0001 ether);
    }

    function burn(uint256 tokenId) public payable {
        // check if the token owner is the same as the sender
        require(
            ownerOf(tokenId) == msg.sender,
            "You are not the owner of this token"
        );
        _burn(tokenId);
        totalSupply--;
    }

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
            toString(tokenId),
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

    function toString(uint256 value) public pure returns (string memory) {
        unchecked {
            bytes16 _SYMBOLS = "0123456789abcdef";
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function toString(int256 value) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    value < 0 ? "-" : "",
                    toString(SignedMath.abs(value))
                )
            );
    }
    /*=====         End of HELPER         ======*/
}
