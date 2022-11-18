// SPDX-License-Identifier: MIT

import "Solidity-Experiments/ETHPool/CustomErrors.sol";
import "Solidity-Experiments/ETHPool/Events.sol";

pragma solidity 0.8.13;

contract Pool is Errors, Events {

address public owner;

address[] public depositers;

mapping (address => uint256) public deposited;

mapping (address => bool) public depositer;

uint256 public poolBalance;

uint256 public rewards;

uint256 public balance;

uint256 public notation = 1e18;

constructor (address _owner) {
    owner = _owner;
}

modifier onlyOwner() {
    if(owner != msg.sender) revert NotOwner();
    _;
}

function changeOwner(address _newOwner) public onlyOwner {
    if(_newOwner == address(0)) revert AddressZero();
    if(owner == _newOwner) revert SameOwner();

    owner = _newOwner;
    
    emit newOwner(msg.sender, _newOwner);
}

function depositETH(uint256 amount) public payable {
    if(amount == 0) revert AmountZero();

    payable(address(this)).transfer(amount);

    poolBalance += amount;

    deposited[msg.sender] += amount;
    depositer[msg.sender] = true;

    depositers.push(msg.sender);
    
    emit deposit(msg.sender, amount);
}

function withdrawETH(uint256 amount) public {
    if(depositer[msg.sender] != true) revert NotDepositer();
    if(amount != deposited[msg.sender]) revert InsufficientFunds();

    if(rewards != 0){
        _distributeRewards(amount);

    } else {
        deposited[msg.sender] -= amount;
        poolBalance -= amount;
        payable(msg.sender).transfer(amount);
    }

    if(deposited[msg.sender] == 0){
        depositer[msg.sender] = false;
    }
    
    emit withdraw(msg.sender, amount);
}

function depositRewards(uint256 amount) public payable onlyOwner {

    depositers.push(msg.sender);

    rewards += amount;

    depositer[msg.sender] = true;

    payable(address(this)).transfer(amount);
    
    emit depositedRewards(msg.sender, amount);
}

function _distributeRewards(uint256 amount) internal {
    for(uint256 i = 0; i < depositers.length; i++){
        address user = depositers[i];

        if(user != owner){
        balance += deposited[user];
        }

        if(user == owner){
            deposited[msg.sender] -= amount;
            poolBalance -= amount;
            uint256 calculateReward = (rewards * ((amount * notation) / balance)) / notation;
            rewards -= calculateReward;
            balance = 0;

            payable(msg.sender).transfer(amount + calculateReward);

            break;
        }
    }  
}

function showPoolBalance() public view returns (uint256){
    if(depositer[msg.sender] != true) revert NotDepositer();
    return poolBalance;
}

receive () external payable {}

}
