// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "Solidity-Experiments/StakingContract/Token.sol";
import "Solidity-Experiments/StakingContract/CustomErrors.sol";
import "Solidity-Experiments/StakingContract/Events.sol";

pragma solidity 0.8.13;

abstract contract Staking is KikiToken, Errors, Events {

mapping(address => uint256) public stakedAmount;

mapping(address => uint256) public stakerLockTime;

mapping(address => uint256) public mintedAmount;

mapping(address => bool) public isStaker;

uint256 public immutable stakingLockTime;

address public immutable Kiki;

address public stakingToken;

address public admin;

constructor (uint256 _lockTime, address _tokenAddress, address _stakingToken) {
    admin = msg.sender;
    stakingLockTime = _lockTime;
    Kiki = _tokenAddress;
    stakingToken = _stakingToken;
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

function changeStakingToken(address _newStakingToken) public onlyAdmin {
    if(_newStakingToken == address(0)) revert AddressZero();
    if(stakingToken == _newStakingToken) revert SameToken();

    stakingToken = _newStakingToken;

    emit newStakingToken(_newStakingToken);
}

function stake(uint256 stakingAmount) public {
    if(stakingAmount == 0) revert ZeroAmount();
    if(isStaker[msg.sender] != false) revert AlreadyStaker();

    isStaker[msg.sender] = true;

    bool success = ERC20(token).transferFrom(msg.sender, address(this), stakingAmount);
    if(!success) revert TransferFailed();

    stakedAmount[msg.sender] += stakingAmount;
    stakerLockTime[msg.sender] = block.timestamp;
    mintedAmount[msg.sender] += stakingAmount;

    KikiToken.mint(stakingAmount);

    emit staker(msg.sender, stakingAmount);
}

function unstake(uint256 unstakingAmount) public {
    if(block.timestamp < stakerLockTime[msg.sender] + stakingLockTime) revert LockTimeNotFinished();
    if(stakedAmount[msg.sender] != unstakingAmount) revert WrongStakedAmount();

    stakedAmount[msg.sender] -= unstakingAmount;

    bool success = ERC20(token).transfer(msg.sender, unstakingAmount);
    if(!success) revert TransferFailed();

    isStaker[msg.sender] = false;

    emit unstaker(msg.sender, unstakingAmount);
}

function claimMintedTokens(uint256 amount) public {
    if(amount == 0) revert ZeroAmount();
    if(amount > mintedAmount[msg.sender]) revert InsufficientAmount();

    mintedAmount[msg.sender] -= amount;

    bool success = ERC20(Kiki).transfer(msg.sender, amount);
    if(!success) revert TransferFailed();

    emit claimedTokens(msg.sender, amount);
}
}
