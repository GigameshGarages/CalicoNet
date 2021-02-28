// SPDX-License-Identifier: Apache License 2.0

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import {
    ISuperToken
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

interface  ISuperAuction {

    event NewWinner(address indexed account, int96 flowRate);
    event DropPlayer(address indexed account);
    event TransferNFT(address indexed to, uint256 indexed tokenId);
    event AuctionClosed();

    struct ViewBidder {
        address account;
        uint256 timeToWin;
        int96 flowRate;
        uint256 balance;
        address nextAccount;
    }

    function _cfa() external view returns (IConstantFlowAgreementV1);
    function _superToken() external view returns(ISuperToken);
    function winner() external view returns(address);
    function winnerFlowRate() external view returns(int96);
    function streamTime() external view returns(uint256);
    function bidders(address account) external view returns(uint256 cumulativeTimer, uint256 lastSettleAmount, address nextAccount);

}