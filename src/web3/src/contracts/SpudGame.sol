// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Spud} from "./SpudNFT.sol";

library GameErrors {
    // Min fee error
    error MinFeeError();
}

contract SpudGame {
    /////////////////////////////////////////////////////////////////////////////
    //                                  Constants                              //
    /////////////////////////////////////////////////////////////////////////////
    // Arbitrary, should be 0.01 ether
    uint256 public constant INITIAL_FEE = 10000000000000000;
    uint256 public constant GAME_DURATION = 1 days;
    Spud public immutable SPUD;
    /////////////////////////////////////////////////////////////////////////////
    //                                  Storage                                //
    /////////////////////////////////////////////////////////////////////////////

    struct Game {
        address currentOwner;
        uint256 prizePool;
        uint256 deadline;
        uint256 currentTokenId;
    }

    mapping(uint256 => Game) public games;
    uint256 public currentGameNonce = 0;

    // Create Spud contract
    constructor() {
        SPUD = new Spud(address(this));
    }

    /// @notice Start the game and pay initial fee. NFT is minted to this contract and can be stolen
    function startGame() external payable {
        if (msg.value < INITIAL_FEE) {
            revert GameErrors.MinFeeError();
        }
        // Mint NFT to this contract
        SPUD.mintNewSpud();
        // Create game
        games[currentGameNonce] = Game({
            currentOwner: msg.sender,
            prizePool: msg.value,
            deadline: block.timestamp + GAME_DURATION,
            currentTokenId: SPUD.currentTokenId() - 1
        });
        // Increase game nonce
        currentGameNonce++;
    }
}
