//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract KikiToken is ERC20("Kiki Token", "KIKI") {

error NotCore();

address public immutable core;

constructor (address _contractAddress) {
    core = _contractAddress;
}

modifier onlyCore() {
    if(msg.sender != core) revert NotCore(); 
    _;
}

function mint(uint256 amount) internal onlyCore {
    _mint(msg.sender, amount);
}

function burn(uint256 amount) internal onlyCore {
    _burn(msg.sender, amount);
}

function checkBalance() public view returns (uint256){
    return ERC20.balanceOf(msg.sender);
}
}

