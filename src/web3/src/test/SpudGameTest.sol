// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/SpudGame.sol";
import "../contracts/SpudNFT.sol";
import "../../../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract SpudGameTest is Test {
    using stdStorage for StdStorage;

    SpudGame public spudGame;
    Spud public spud;
    address public player;
    ERC20 public LINK = ERC20(address(0x779877A7B0D9E8603169DdbD7836e478b4624789));
    address public constant WRAPPER = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    function setStorage(address _user, bytes4 _selector, address _contract, uint256 value) public {
        uint256 slot = stdstore.target(_contract).sig(_selector).with_key(_user).find();
        vm.store(_contract, bytes32(slot), bytes32(value));
    }

    function setUp() public {
        vm.createSelectFork("sepolia", 4_879_358);
        // Deploy the SpudGame contract and the Spud contract within it
        spudGame = new SpudGame();
        spud = spudGame.SPUD();
        player = address(1);

        // Assign some ETH to the player address
        vm.deal(player, 5 ether);

        // Start the game with the player sending the initial fee
        vm.startPrank(player);
        spudGame.startGame{ value: 1 ether }();
        vm.stopPrank();
    }

    function testStartGame() public {
        // Check that the game started and the NFT was minted
        (address currentOwner,,,,,,) = spudGame.getGame(0);
        assertEq(currentOwner, player);
        assertTrue(spud.balanceOf(address(spudGame), 0) == 1);
    }

    function testStealNFT(uint256 guess) public {
        vm.assume(guess < 21);
        // Another player tries to steal the NFT
        address thief = address(2);
        vm.deal(thief, 1 ether);

        vm.startPrank(thief);
        // Give LINK to the contract
        setStorage(address(spudGame), LINK.balanceOf.selector, address(LINK), 100e18);
        spudGame.stealNFT{ value: 1 ether }(0, guess);
        vm.stopPrank();

        // Check the new owner is the thief
        (address currentOwner,,,,,,) = spudGame.getGame(0);
        assertEq(currentOwner, thief);

        // Check game's requestID from VRF:
        (,,,, uint256 requestId,,) = spudGame.getGame(0);
        // Now fullfill the request with a guess and make sure it's exploded
        vm.startPrank(WRAPPER);
        uint256[] memory randomWords = new uint256[](1);
        randomWords[0] = guess;
        spudGame.rawFulfillRandomWords(requestId, randomWords);
        vm.stopPrank();
        // Check that game is exploded
        (,,,,,, bool exploded) = spudGame.getGame(0);
        assertTrue(exploded);

        // Last owner should be able to claim:
        vm.startPrank(thief);
        spudGame.claimPrizePool(0);

        // Check the prize pool was transferred
        assertEq(address(spudGame).balance, 0);
        assertEq(address(thief).balance, 2 ether);
        // Check NFT belongs to the player
        assertEq(spud.balanceOf(thief, 0), 1);
    }

    function testClaimPrizePool() public {
        // Simulate time passing and the game ending
        vm.warp(block.timestamp + 2 days);
        uint256 etherSnapshot = address(spudGame).balance;
        // Log the current time and game deadline for debugging
        (,, uint256 deadline,,,,) = spudGame.getGame(0);
        console.log("Current timestamp:", block.timestamp);
        console.log("Game deadline:", deadline);

        // Player attempts to claim the prize pool
        vm.startPrank(player);
        spudGame.claimPrizePool(0);
        vm.stopPrank();

        // Check the prize pool was transferred
        assertEq(address(spudGame).balance, 0);

        // Make sure winner has NFT and prize pool
        assertEq(player.balance, 5e18);
        // Check NFT belongs to the player
        assertEq(spud.balanceOf(player, 0), 1);
    }
}
