// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract Pool {

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
    if(owner != msg.sender) revert();
    _;
}

function changeOwner(address _newOwner) public onlyOwner {
    if(_newOwner == address(0)) revert();
    if(owner == _newOwner) revert();

    owner = _newOwner;
}

function depositETH(uint256 amount) public payable {
    if(amount == 0) revert();

    payable(address(this)).transfer(amount);

    poolBalance += amount;

    deposited[msg.sender] += amount;
    depositer[msg.sender] = true;

    depositers.push(msg.sender);
}

function withdrawETH(uint256 amount) public {
    if(depositer[msg.sender] != true) revert();
    if(amount != deposited[msg.sender]) revert();

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
}

function depositRewards(uint256 amount) public payable onlyOwner {

    depositers.push(msg.sender);

    rewards += amount;

    depositer[msg.sender] = true;

    payable(address(this)).transfer(amount);
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
    if(depositer[msg.sender] != true) revert();
    return poolBalance;
}

receive () external payable {}

}
