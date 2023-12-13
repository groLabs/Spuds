// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Spud } from "./SpudNFT.sol";
import { ERC1155Holder } from "../../../../lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { VRFV2WrapperConsumerBase } from
    "../../../../lib/foundry-chainlink-toolkit/lib/chainlink-brownie-contracts/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

library GameErrors {
    // Min fee error
    error MinFeeError();
    error GameEnded();
    error GameNotEnded();
    error NotEnoughToSteal();
    error InvalidGuess();
}

contract SpudGame is ERC1155Holder, VRFV2WrapperConsumerBase {
    /////////////////////////////////////////////////////////////////////////////
    //                                  Constants                              //
    /////////////////////////////////////////////////////////////////////////////
    // Arbitrary, should be 0.01 ether
    uint256 public constant INITIAL_FEE = 10_000_000_000_000_000;
    uint256 public constant FEE_TO_STEAL = 10_000_000_000_000_000;
    uint256 public constant GAME_DURATION = 1 days;
    Spud public immutable SPUD;

    // VRF
    uint32 public CALLBACK_GAS_LIMIT = 100_000;
    uint16 public REQUEST_CONFIRMATIONS = 3;
    uint32 public NUM_WORDS = 1;
    uint256 public constant MODULO = 21;

    // Address LINK - hardcoded for Sepolia
    address public constant LINK_ADDRESS = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address public constant WRAPPER = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;
    /////////////////////////////////////////////////////////////////////////////
    //                                  Storage                                //
    /////////////////////////////////////////////////////////////////////////////

    struct Game {
        address currentSpudOwner;
        uint256 prizePool;
        uint256 deadline;
        uint256 tokenId;
        uint256 requestId;
        uint256[] guesses;
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
    constructor() VRFV2WrapperConsumerBase(LINK_ADDRESS, WRAPPER) {
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
        returns (
            address currentSpudOwner,
            uint256 prizePool,
            uint256 deadline,
            uint256 tokenId,
            uint256 requestId,
            uint256[] memory guesses,
            bool exploded
        )
    {
        Game memory game = games[_gameId];
        currentSpudOwner = game.currentSpudOwner;
        prizePool = game.prizePool;
        deadline = game.deadline;
        tokenId = game.tokenId;
        exploded = game.exploded;
        requestId = game.requestId;
        guesses = game.guesses;
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
            requestId: 0,
            guesses: new uint256[](0),
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
    function stealNFT(uint256 _gameId, uint256 _guess) external payable {
        // Require guess to be between 0 and 20
        if (_guess > 20) {
            revert GameErrors.InvalidGuess();
        }
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
        game.guesses.push(_guess);
        emit NFTStolen(_gameId, oldOwner, msg.sender, game.prizePool);
        // Make request to VRF to generate random words
        uint256 requestId = requestRandomness(CALLBACK_GAS_LIMIT, REQUEST_CONFIRMATIONS, NUM_WORDS);
        game.requestId = requestId;
    }

    /// @notice Claim prize pool of the game if the game has ended
    /// @param _gameId Game ID to claim
    function claimPrizePool(uint256 _gameId) external {
        Game storage game = games[_gameId];
        // Check if game is still active
        require(block.timestamp > game.deadline || game.exploded, "GameNotEnded");
        // Update game
        game.exploded = true;
        // Transfer prize pool to the current owner
        payable(game.currentSpudOwner).call{ value: game.prizePool }("");
        etherBalance -= game.prizePool;

        // Transfer NFT to the current owner too
        SPUD.safeTransferFrom(address(this), game.currentSpudOwner, game.tokenId, 1, "");
        emit ClaimedPrizePool(_gameId, game.currentSpudOwner, game.prizePool);
    }

    /////////////////////////////////////////////////////////////////////////////
    //                                   VRF hook                              //
    /////////////////////////////////////////////////////////////////////////////
    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        // Search for game with the request ID
        for (uint256 i = 0; i < currentGameNonce; i++) {
            Game storage game = games[i];
            if (game.requestId == _requestId) {
                // Iterate over all guesses made and if one of them matches the random word, explode the game
                for (uint256 j = 0; j < game.guesses.length; j++) {
                    if (_randomWords[0] % MODULO == game.guesses[j]) {
                        game.exploded = true;
                        break;
                    }
                }
            }
        }
    }
}
