// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "contracts/Staking/Token.sol";
import "contracts/Staking/CustomErrors.sol";
import "contracts/Staking/Events.sol";


pragma solidity 0.8.13;

abstract contract Staking is KikiToken, Errors, Events {

mapping(address => uint256) public stakedAmount;

mapping(address => uint256) public stakerLockTime;

mapping(address => bool) public isStaker;

uint256 public immutable stakingLockTime;

address public admin;

address public token;

constructor (uint256 _lockTime) {
    admin = msg.sender;
    stakingLockTime = _lockTime;
}

modifier onlyAdmin() {
    if(msg.sender != admin) revert NotAdmin();
    _;
}

function changeAdmin(address _newAdmin) public onlyAdmin {
    if(_newAdmin == address(0)) revert AddressZero();
    if(admin == _newAdmin) revert SameAdmin();

    admin = _newAdmin;
    
    emit newAdmin(_newAdmin);
}

function changeStakingToken(address _token) public onlyAdmin {
    if(_token == address(0)) revert AddressZero();
    if(token == _token) revert SameToken();

    token = _token;

    emit newStakingToken(_token);
}

function stake(uint256 stakingAmount) public {
    if(stakingAmount == 0)  revert ZeroAmount();
    if(isStaker[msg.sender] != false) revert AlreadyStaker();

    isStaker[msg.sender] = true;

    bool success = ERC20(token).transferFrom(msg.sender, address(this), stakingAmount);
    if (!success) revert TransferFailed();

    stakedAmount[msg.sender] += stakingAmount;
    stakerLockTime[msg.sender] = block.timestamp;

    KikiToken.mint(stakingAmount);

    emit staker(msg.sender, stakingAmount);
}

function unstake(uint256 unstakingAmount) public {
    if(block.timestamp > stakerLockTime[msg.sender] + stakingLockTime) revert LockTimeNotFinished();
    if(stakedAmount[msg.sender] != unstakingAmount) revert WrongStakedAmount();

    stakedAmount[msg.sender] -= unstakingAmount;

    bool success = ERC20(token).transfer(msg.sender, unstakingAmount);
    if (!success) revert TransferFailed();

    isStaker[msg.sender] = false;

    emit unstaker(msg.sender, unstakingAmount);
}
}
