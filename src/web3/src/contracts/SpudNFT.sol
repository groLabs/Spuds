// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1155} from "../../../../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract Spud is ERC1155 {
    constructor() ERC1155("https://spud.finance/api/token/{id}.json") {}
}
