// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Events {

event newOwner(address indexed owner, address indexed newOwner);
event deposit(address indexed depositer, uint256 amount);
event withdraw(address indexed withdrawer, uint256 amount);
event depositedRewards(address indexed owner, uint256 amount);

}
