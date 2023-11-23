// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Spud } from "./SpudNFT.sol";

library GameErrors {
    // Min fee error
    error MinFeeError();
    error GameEnded();
    error GameNotEnded();
    error NotEnoughToSteal();
}

contract SpudGame {
    /////////////////////////////////////////////////////////////////////////////
    //                                  Constants                              //
    /////////////////////////////////////////////////////////////////////////////
    // Arbitrary, should be 0.01 ether
    uint256 public constant INITIAL_FEE = 10_000_000_000_000_000;
    uint256 public constant FEE_TO_STEAL = 10_000_000_000_000_000;
    uint256 public constant GAME_DURATION = 1 days;
    Spud public immutable SPUD;
    /////////////////////////////////////////////////////////////////////////////
    //                                  Storage                                //
    /////////////////////////////////////////////////////////////////////////////

    struct Game {
        address currentSpudOwner;
        uint256 prizePool;
        uint256 deadline;
        uint256 tokenId;
        bool exploded;
    }

    mapping(uint256 => Game) public games;
    uint256 public currentGameNonce = 0;
    // Internal accounting for ether
    // balance
    uint256 public etherBalance;

    /////////////////////////////////////////////////////////////////////////////
    //                                  Events                                 //
    /////////////////////////////////////////////////////////////////////////////
    event GameStarted(
        uint256 indexed gameId, address indexed currentSpudOwner, uint256 prizePool, uint256 deadline, uint256 tokenId
    );
    event NFTStolen(uint256 indexed gameId, address indexed previousOwner, address indexed newOwner, uint256 prizePool);
    event ClaimedPrizePool(uint256 indexed gameId, address indexed winner, uint256 prizePool);

    // Create Spud contract
    constructor() {
        SPUD = new Spud(address(this));
    }
    /////////////////////////////////////////////////////////////////////////////
    //                                   VIEWS                                 //
    /////////////////////////////////////////////////////////////////////////////

    /// @notice View function to get the current game status
    /// @return currentSpudOwner Current owner of the NFT
    /// @return prizePool Current prize pool
    /// @return deadline Deadline of the game
    /// @return tokenId token ID used for the game
    function getGame(uint256 _gameId)
        external
        view
        returns (address currentSpudOwner, uint256 prizePool, uint256 deadline, uint256 tokenId, bool exploded)
    {
        Game memory game = games[_gameId];
        currentSpudOwner = game.currentSpudOwner;
        prizePool = game.prizePool;
        deadline = game.deadline;
        tokenId = game.tokenId;
        exploded = game.exploded;
    }

    /////////////////////////////////////////////////////////////////////////////
    //                                   CORE                                  //
    /////////////////////////////////////////////////////////////////////////////

    /// @notice Start the game and pay initial fee. NFT is minted to this contract and can be stolen
    function startGame() external payable {
        if (msg.value < INITIAL_FEE) {
            revert GameErrors.MinFeeError();
        }
        // Mint NFT to this contract
        SPUD.mintNewSpud();
        // Create game
        games[currentGameNonce] = Game({
            currentSpudOwner: msg.sender,
            prizePool: msg.value,
            deadline: block.timestamp + GAME_DURATION,
            tokenId: SPUD.currentTokenId() - 1,
            exploded: false
        });
        // Increase game nonce
        currentGameNonce++;
        etherBalance += msg.value;
        emit GameStarted(
            currentGameNonce - 1, msg.sender, msg.value, block.timestamp + GAME_DURATION, SPUD.currentTokenId() - 1
        );
    }

    /// @notice Steal NFT from other player, by depositing more ether
    /// @param _gameId Game ID to steal
    function stealNFT(uint256 _gameId) external payable {
        Game storage game = games[_gameId];
        // Check if game is still active
        if (block.timestamp > game.deadline) {
            revert GameErrors.GameEnded();
        }
        if (msg.value < FEE_TO_STEAL) {
            revert GameErrors.NotEnoughToSteal();
        }
        // Update game
        address oldOwner = game.currentSpudOwner;
        game.currentSpudOwner = msg.sender;
        game.prizePool += msg.value;
        etherBalance += msg.value;
        emit NFTStolen(_gameId, oldOwner, msg.sender, game.prizePool);
        // TODO: Logic to explode and end the game based on random number
    }

    /// @notice Claim prize pool of the game if the game has ended
    /// @param _gameId Game ID to claim
    function claimPrizePool(uint256 _gameId) external {
        Game storage game = games[_gameId];
        // Check if game is still active
        if (block.timestamp < game.deadline) {
            revert GameErrors.GameNotEnded();
        }
        // Check if game has already exploded
        if (game.exploded) {
            revert GameErrors.GameEnded();
        }
        // Update game
        game.exploded = true;
        // Transfer prize pool to the current owner
        payable(game.currentSpudOwner).transfer(game.prizePool);
        etherBalance -= game.prizePool;

        // Transfer NFT to the current owner too
        SPUD.safeTransferFrom(address(this), game.currentSpudOwner, game.tokenId, 1, "");
        emit ClaimedPrizePool(_gameId, game.currentSpudOwner, game.prizePool);
    }
}
