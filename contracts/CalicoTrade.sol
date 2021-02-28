// SPDX-License-Identifier: Apache License 2.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "./IERC20.sol";
import "./IERC721.sol";

contract CalicoTrade  {

    enum Status {Initiated, Success, Withdrawn}

    struct ExchangeData {
        address party1;
        address party2;
        address token1;
        address token2;
        uint tokenID;
        uint amount2OrTokenID;
        uint expiry; // Time in seconds after which the transaction can be automatically executed if not disputed.
        bool party2Confirmation; // Last interaction for the dispute procedure.
        Status status;
    }


    // mapping(uint => IERC20) tokenInstance;


    ExchangeData[] public exchange;

    event ExchangeCreated(uint _exchangeID, address indexed _party1, address _token1, uint _amount1, address _token2, uint _amount2);

    event ExchangeStatusChange(uint _exchangeID, uint _status);

    function createExchange(
        uint _tokenId,
        address _token1,
        uint _expiry,
        address _token2,
        uint _amount2OrTokenId
    ) public returns (uint exchangeIndex) {
        IERC721 senderToken = IERC721(_token1); // both ERC20 and ERC721 have same signature for transfer and transferFrom.
        // Transfers token from sender wallet to contract.
        
        require(senderToken.transferFrom(msg.sender, address(this), _tokenId), "Sender does not have enough approved funds.");
        exchangeIndex = exchange.length;
        exchange.push(ExchangeData({
            party1: msg.sender,
            party2: address(0),
            token1: _token1,
            token2: _token2,
            tokenID: _tokenId,
            amount2OrTokenID: _amount2OrTokenId,
            expiry: now + _expiry,
            party2Confirmation: false,
            status: Status.Initiated
        }));
        
        emit ExchangeCreated(exchangeIndex, msg.sender, _token1, _tokenId, _token2, _amount2OrTokenId);
        emit ExchangeStatusChange(exchangeIndex, uint(Status.Initiated));

    }

    function party2Response(uint _exchangeID) public {
        ExchangeData storage exchangeData = exchange[_exchangeID];
        require(exchangeData.status == Status.Initiated);
        require(exchangeData.expiry > now);
        IERC721 senderToken = IERC721(exchangeData.token1); // both ERC20 and ERC721 have same signature for transfer and transferFrom.

        IERC20 party2Token = IERC20(exchangeData.token2); // both ERC20 and ERC721 have same signature for transfer and transferFrom.
        require(senderToken.transfer(msg.sender, exchangeData.tokenID), "Transfer to party2 failed.");
        require(party2Token.transferFrom(msg.sender, exchangeData.party1, exchangeData.amount2OrTokenID), "party2 does not have enough approved funds.");
        exchangeData.party2 == msg.sender;
        
        exchange[_exchangeID].status = Status.Success;
        exchange[_exchangeID].party2Confirmation = true;
        emit ExchangeStatusChange(_exchangeID, uint(Status.Success));

        
    }

    function withdrawRequest(uint _exchangeID) public {
        ExchangeData storage exchangeData = exchange[_exchangeID];
        require(exchangeData.party1 == msg.sender);
        require(exchangeData.status == Status.Initiated);

        IERC721 senderToken = IERC721(exchangeData.token1);   // both ERC20 and ERC721 have same signature for transfer and transferFrom.
        
        require(senderToken.transfer(msg.sender, exchangeData.tokenID), "Transfer to party1 failed.");
        exchange[_exchangeID].status = Status.Withdrawn;
        emit ExchangeStatusChange(_exchangeID, uint(Status.Withdrawn));
    }


    function getCountExchange() public view returns (uint count) {
        return exchange.length;
    }

}
