
// SPDX-License-Identifier: Apache License 2.0

pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import { ERC721Full } from "./ERC721Full.sol";
import { SafeMath } from "./SafeMath.sol";


/**
 * @notice - This is the NFT contract for a Public Art
 */
contract PublicNFT is ERC721Full {
    using SafeMath for uint256;

    uint256 public currentPhotoId;

    struct PhotoData {  /// [Key]: photoNFT contract address
        string photoNFTName;
        string photoNFTSymbol;
        address ownerAddress;
        uint photoPrice;
        string ipfsHashOfPhoto;
        uint256 reputation;
    }
    mapping (address => PhotoData) photoDatas;  /// [Key]: photoNFT contract address
    
    constructor(
        address owner,  /// Initial owner (Seller)
        string memory _nftName, 
        string memory _nftSymbol,
        string memory _tokenURI,    /// [Note]: TokenURI is URL include ipfs hash
        uint photoPrice
    ) 
        public 
        ERC721Full(_nftName, _nftSymbol) 
    {
        mint(owner, _tokenURI);
    }

    /** 
     * @notice - Save a photoNFT data
     */
    function savePhotoNFTData(string memory _photoNFTName, string memory _photoNFTSymbol, address _ownerAddress, uint _photoPrice, string memory _ipfsHashOfPhoto) public returns (bool) {
        PhotoData storage photoData = photoDatas[address(this)];
        photoData.photoNFTName = _photoNFTName;
        photoData.photoNFTSymbol = _photoNFTSymbol;
        photoData.ownerAddress = _ownerAddress;
        photoData.photoPrice = _photoPrice;
        photoData.ipfsHashOfPhoto = _ipfsHashOfPhoto;
        photoData.reputation = 0;
    }

    /** 
     * @dev mint a photoNFT
     * @dev tokenURI - URL include ipfs hash
     */
    function mint(address to, string memory tokenURI) public returns (bool) {
        /// Mint a new PhotoNFT
        uint newPhotoId = getNextPhotoId();
        currentPhotoId++;
        _mint(to, newPhotoId);
        _setTokenURI(newPhotoId, tokenURI);
    }


    ///--------------------------------------
    /// Getter methods
    ///--------------------------------------
    function getPhotoData(address photoNFTContractAddress) public view returns (PhotoData memory _photoData) {
        PhotoData memory photoData = photoDatas[photoNFTContractAddress];
        return photoData;
    }



    ///--------------------------------------
    /// Private methods
    ///--------------------------------------
    function getNextPhotoId() private returns (uint nextPhotoId) {
        return currentPhotoId.add(1);
    }
    

}
