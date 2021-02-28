// SPDX-License-Identifier: Apache License 2.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import { ERC721 } from "./ERC721.sol";
import { SafeMath } from "./SafeMath.sol";
import "./AccessControl.sol";


contract CalicoCommonToken is ERC721, AccessControl {
    
    using SafeMath for uint;

    uint public currentAuthTokenId;

    bytes32 public constant USER_ROLE = keccak256("USER_ROLE");

    constructor(
        address to,
        string memory ipfsHash
        //IERC20 _mUSD,
        //ISavingsContract _save,
        //IMStableHelper _helper
    ) 
        public 
        ERC721("NFT Auth Token", "NAT")
    {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mintAuthToken(address to, string memory ipfsHash) public returns (uint _newAuthTokenId) {
        _mintAuthToken(to, ipfsHash);

        /// Grant an user who is minted the AuthToken the user-role
        _setupRole(USER_ROLE, to);
    }

    function _mintAuthToken(address to, string memory ipfsHash) internal returns (uint _newAuthTokenId) {
        uint newAuthTokenId = getNextAuthTokenId();
        currentAuthTokenId++;
        _mint(to, newAuthTokenId);
        _setTokenURI(newAuthTokenId, ipfsHash);  /// [Note]: Use ipfsHash as a password and metadata
        //_setTokenURI(newAuthTokenId, authTokenURI); 

        return newAuthTokenId;
    }

    function loginWithAuthToken(uint authTokenId, address userAddress, string memory ipfsHash) public view returns (bool _isAuth) {
        /// [Note]: Check whether a login user has role or not
        require(hasRole(USER_ROLE, userAddress), "Caller is not a user");

        /// [Note]: Convert each value (data-type are string) to hash in order to compare with each other 
        bytes32 hash1 = keccak256(abi.encodePacked(ipfsHash));
        bytes32 hash2 = keccak256(abi.encodePacked(tokenURI(authTokenId)));

        /// Check 
        bool isAuth;
        if (userAddress == ownerOf(authTokenId)) {
            if (hash1 == hash2) {
                isAuth = true;
            }
        }

        return isAuth;
    }

    function getNextAuthTokenId() private view returns (uint nextAuthTokenId) {
        return currentAuthTokenId.add(1);
    }

}
