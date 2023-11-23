// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1155} from "../../../../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract Spud is ERC1155 {
    address public immutable GAME_CONTRACT;
    uint256 public currentTokenId = 0;

    constructor(address gameContract) ERC1155("https://spud.finance/api/token/{id}.json") {
        GAME_CONTRACT = gameContract;
    }

    /// @notice External mint function for Spud, can be used only by the game contract
    function mintNewSpud() external {
        require(msg.sender == GAME_CONTRACT, "Spud: Only game contract can mint");
        // Check the current token ID
        _mint(msg.sender, currentTokenId, 1, "");
        currentTokenId++;
    }
}
