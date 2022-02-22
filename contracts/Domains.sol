// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "../libraries/StringUtils.sol";
import { Base64 } from "../libraries/Base64.sol";
import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
	// Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

	// Here's our domain TLD!
  string public tld;

		// We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg width="599" height="599" viewBox="0 0 599 599" fill="none" xmlns="http://www.w3.org/2000/svg"><g filter="url(#a)" fill="#000"><path d="M352.848 3.27c-29.798 7-61.666 16.332-72.426 21.386-5.794 2.333-22.763 10.11-37.662 16.72-14.899 6.61-30.626 15.554-34.765 19.831-4.138 4.277-9.933 7.777-13.244 7.777-2.897 0-5.38 1.555-5.38 3.11 0 1.556-6.208 6.222-13.243 10.499-29.385 15.553-55.458 37.328-100.984 83.988-60.838 62.214-90.222 161.756-67.46 229.024 4.967 14.776 10.347 27.219 12.416 27.219 1.656 0 8.691 8.943 15.727 19.442 14.072 21.386 23.177 24.496 30.212 10.109 3.725-8.554 2.07-12.831-12.002-34.217-9.105-13.609-19.038-33.829-21.935-45.494-5.38-21.386-3.724-57.547 3.725-74.656 2.07-5.055 6.208-17.109 9.105-26.83 17.383-58.714 79.462-126.371 160.994-176.142 55.044-33.44 71.185-40.828 121.263-54.826 88.981-25.275 161.821-5.444 206.518 55.603 23.591 32.662 28.143 45.494 28.143 80.878 0 30.329-12.829 68.435-28.556 84.377-4.139 4.666-9.105 12.054-10.347 16.72-1.656 4.666-9.933 14.387-18.21 21.386-8.691 7.388-20.693 20.997-26.901 30.718-6.208 9.332-18.21 24.886-26.074 34.218-17.382 20.608-17.382 32.662-.414 34.606 14.486 1.555 37.248-13.998 46.767-31.496 7.036-12.442 31.868-42.771 50.492-60.658 14.485-14.776 46.353-71.546 46.767-84.377 0-6.222 1.655-14.387 3.31-18.664 4.139-9.721-2.069-62.214-10.346-85.544-3.311-10.499-10.761-24.886-16.555-31.496-5.38-6.999-9.933-13.998-10.347-15.942 0-3.11-25.245-23.33-54.216-43.16-24.418-16.72-56.7-25.664-98.5-26.83-21.521-.39-46.767.777-55.872 2.721Z"/><path d="M330.086 245.904c-7.864 2.722-21.521 6.221-29.799 7.777-9.932 1.555-19.038 6.61-27.729 15.553-10.76 11.665-12.002 14.776-8.691 25.663 7.45 23.33 40.145 46.272 66.632 46.272 21.935 0 35.593-12.832 45.112-42.383 10.346-33.829 10.346-34.607-2.897-47.827-12.416-12.054-21.107-13.221-42.628-5.055Zm-171.755 32.662c-9.105 3.889-21.935 8.555-28.143 9.721-14.485 3.111-28.97 23.719-25.659 37.328 1.241 5.444 7.449 13.998 14.071 19.442 43.456 36.551 50.492 38.106 64.149 15.165 4.967-7.777 13.658-21.386 20.28-30.33 15.313-21.774 15.313-40.05-.828-50.548-14.899-10.11-22.763-10.11-43.87-.778Zm66.219 58.714c-28.971 17.109-40.973 58.714-22.763 76.99 13.658 13.609 28.971 9.721 40.559-9.332 2.897-5.055 5.38-5.055 14.485-1.167 8.692 3.888 13.244 3.111 26.488-3.111 8.691-4.277 18.624-12.442 21.935-17.886 5.38-9.332 5.38-10.887-2.07-20.608-9.519-11.665-45.939-32.274-57.941-32.274-4.552-.388-14.071 3.111-20.693 7.388Zm147.75 69.602c-8.277 4.666-4.139 17.886 5.38 17.886 5.794 0 8.277-2.722 8.277-9.332 0-10.498-5.38-13.609-13.657-8.554ZM28.791 570.193c-8.277 4.666-4.138 17.886 5.38 17.886 5.795 0 8.278-2.722 8.278-9.332 0-10.498-5.38-13.609-13.658-8.554Zm420.074-146.202c-16.141 13.609-19.452 19.441-19.452 30.329 0 7.388 2.484 16.72 5.794 20.997 2.898 4.277 6.622 21.775 8.278 38.495 2.897 36.939 9.105 45.104 32.695 45.104 19.452 0 46.767-13.609 50.078-24.496 1.242-4.666 1.242-8.943 0-10.11-.828-1.166-12.83 0-26.487 1.944l-24.832 3.889v-18.664c0-16.72 1.241-19.442 10.346-22.553 5.794-1.944 15.313-8.554 20.694-14.387l9.932-10.887-11.174-2.333c-6.208-1.167-17.382 0-25.246 3.11-11.588 4.278-14.899 4.278-17.796.389-5.38-8.554-3.725-12.831 11.174-26.441 16.141-14.775 17.797-28.385 3.725-30.329-5.38-.777-15.313 5.055-27.729 15.943Zm-155.2 26.052c-4.966 1.944-12.416 9.72-16.14 17.497-6.622 12.832-6.622 15.554 0 41.606 3.724 15.553 7.863 36.939 9.519 47.049 3.31 23.719 13.243 35.772 26.073 31.884 9.105-2.722 9.519-4.277 7.036-22.163l-2.897-19.831 15.727 2.722c41.386 6.999 57.113 7.388 62.907 1.166 2.897-3.499 7.45-5.443 10.347-4.277 2.897 1.167 7.449-.778 10.347-3.888 5.794-6.61.413-36.162-12.416-68.435-13.658-33.44-32.696-18.664-21.521 16.72 3.31 10.109 4.552 20.219 3.31 22.163-1.241 1.944-.413 4.277 2.07 5.833 2.069 1.166 4.138 5.443 4.138 9.332 0 6.61-.827 6.999-17.382 1.166-17.382-5.832-17.796-6.221-18.624-24.496-1.241-22.164-8.277-33.829-29.798-47.827-16.555-10.887-18.624-11.276-32.696-6.221Zm19.866 23.33c8.691 4.277 17.796 27.218 14.071 36.161-6.208 15.554-22.348 10.11-22.348-7.776 0-4.666-1.656-9.721-4.139-10.888-5.38-3.11-5.38-21.386.414-21.386 2.483 0 7.863 1.556 12.002 3.889Zm-200.311-9.332c-3.725 3.11-7.036 12.442-7.036 20.219-.414 7.777-2.069 19.442-3.311 26.052l-2.897 11.665-6.622-13.998c-3.724-7.777-7.863-17.498-9.105-22.164-4.552-12.831-16.968-17.886-24.832-10.109-4.966 4.666-6.621 13.998-6.208 37.717.414 54.826 16.141 109.651 19.452 66.879.414-8.554 2.07-19.83 3.311-24.885l2.07-9.721 9.104 10.11c10.347 11.276 22.349 16.331 25.66 10.887 5.38-8.165 13.658-3.111 16.141 9.332 1.655 8.166 7.036 15.942 13.244 19.831 10.346 6.221 11.174 6.221 18.21-.389 7.035-6.999 7.035-9.332-2.897-57.936-14.486-69.991-26.488-90.21-44.284-73.49Zm88.567 12.831c0 1.944-4.138 5.055-9.105 6.61-19.038 5.055-24.004 13.221-24.004 36.551 0 38.495 16.555 62.214 42.628 62.214 28.971 0 48.836-31.496 45.112-71.157-1.656-16.331-3.725-19.831-16.555-27.996-14.899-9.721-38.076-13.221-38.076-6.222Zm27.315 40.828c2.897 11.665-4.966 35.773-12.829 38.883-7.036 2.333-12.003-3.11-18.211-20.608-6.208-17.886-5.794-19.442 4.967-23.719 15.727-5.832 23.176-4.277 26.073 5.444Z"/></g><defs><filter id="a" x=".002" y=".474" width="600" height="604" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB"><feFlood flood-opacity="0" result="BackgroundImageFix"/><feBlend in="SourceGraphic" in2="BackgroundImageFix" result="shape"/><feColorMatrix in="SourceAlpha" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/><feOffset dy="4"/><feGaussianBlur stdDeviation="2"/><feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/><feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/><feBlend in2="shape" result="effect1_innerShadow_27_83"/></filter></defs><text x="120" y="200" font-size="24" fill="#FC4945" font-family="Courier New, sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  mapping(string => address) public domains;
  mapping(string => string) public records;
		
  // We make the contract "payable" by adding this to the constructor
	constructor(string memory _tld) payable ERC721("Morie Name Service", "MNS") {
		tld = _tld;
		console.log("%s name service deployed", _tld);
	}

  // This function will give us the price of a domain based on length
  function price(string calldata name) public pure returns(uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
    } else if (len == 4) {
      return 3 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.3
    } else {
      return 1 * 10**17;
    }
  }

	function register(string calldata name) public payable {
    require(domains[name] == address(0));

    uint256 _price = price(name);
    require(msg.value >= _price, "Not enough Matic paid");
		
		// Combine the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", tld));
		// Create the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newRecordId = _tokenIds.current();
  	uint256 length = StringUtils.strlen(name);
		string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

		// Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            _name,
            '", "description": "A domain on the Morie name service", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

		console.log("\n--------------------------------------------------------");
	  console.log("Final tokenURI", finalTokenUri);
	  console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;

    _tokenIds.increment();
  }

  // This will give us the domain owners' address
  function getAddress(string calldata name) public view returns (address) {
		// Check that the owner is the transaction sender
		return domains[name];
  }

	function setRecord(string calldata name, string calldata record) public {
		// Check that the owner is the transaction sender
		require(domains[name] == msg.sender);
		records[name] = record;
  }

  function getRecord(string calldata name) public view returns(string memory) {
		return records[name];
  }
}