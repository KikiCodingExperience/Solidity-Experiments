// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Events {

event staker(address indexed staker, uint256 stakingAmount);
event unstaker(address indexed staker, uint256 unstakingAmount);
event newAdmin(address indexed newAdmin);
event newStakingToken(address indexed token);
event claimedTokens(address indexed sender, uint256 amount);

}
