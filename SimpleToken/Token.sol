//SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract KikiToken is ERC20("Kiki Token", "KIKI") {

    mapping (address => bool) public isOwner;

    address public owner;

    constructor () {
        owner = msg.sender;
        isOwner[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner"); 
        _;
    }

    function mint(uint256 amount) public onlyOwner {
        require(amount > 0, "Zero Amount");
        _mint(msg.sender, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        require(amount > 0, "Zero Amount");
        _burn(msg.sender, amount);
    }

    function checkBalance() public view returns (uint256){
        return ERC20.balanceOf(msg.sender);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Zero address");
        require(owner != _newOwner, "Same Owner");
        isOwner[msg.sender] = false;
        owner = _newOwner;
        isOwner[_newOwner] = true;
    }

}
