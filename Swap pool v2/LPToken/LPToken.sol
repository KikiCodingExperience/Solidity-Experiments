// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/AccessControl.sol";

contract KikiLP is ERC20("KikiLP Token","KIKI"), AccessControl {

bytes32 public constant pool = keccak256("LiquidityPool");

constructor (address _poolAddress) {

_grantRole(pool, _poolAddress);

}

modifier onlyPool() {
    if(!hasRole(pool, msg.sender)) revert();
    _;
}

function mint(uint256 amount) public onlyPool {
    _mint(msg.sender, amount);
}

function burn(address account, uint256 amount) public onlyPool {
    _burn(account, amount);
}

}
