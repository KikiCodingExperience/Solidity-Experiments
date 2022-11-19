// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "KikiV2/LPToken.sol";

pragma solidity 0.8.13;

contract Pool is KikiLP(address(this)) {

constructor (address _liquidityTokenA, address _liquidityTokenB, address _kikiToken) {
    owner = msg.sender;
    liquidityTokenA = _liquidityTokenA;
    liquidityTokenB = _liquidityTokenB;
    kiki = _kikiToken;
}

modifier onlyLiquidityPool() {
    if(msg.sender != address(this)) revert();
    _;
}

modifier onlyProvider() {
    if(!isProvider[msg.sender]) revert();
    _;
}

mapping(address => mapping(address => uint256)) public liquidityProvider;

mapping(address => uint256) public mintedAmount;

mapping(address => bool) public isProvider;

address public owner;

address public immutable liquidityTokenA;

address public immutable liquidityTokenB;

address public immutable kiki;

uint256 public poolBalanceTokenA;

uint256 public poolBalanceTokenB;

uint256 public notation;

function depositTokenA(uint256 amount) public {
    if(amount == 0) revert();

    bool success = ERC20(liquidityTokenA).transferFrom(msg.sender, address(this), amount);
    if(!success) revert();

    KikiLP.mint(amount);

    liquidityProvider[liquidityTokenA][msg.sender] += amount;
    mintedAmount[msg.sender] += amount;
    poolBalanceTokenA += amount;

    isProvider[msg.sender] = true;

    claimMintedAmount();
}

function withdrawTokenA(address to, uint256 amount) public onlyProvider {
    if(amount == 0) revert();
    if(amount > liquidityProvider[liquidityTokenA][msg.sender]) revert();

    require(ERC20(kiki).transferFrom(msg.sender, address(this), amount));

    KikiLP.burn(msg.sender, amount);

    uint256 holderPercent = percentPoolHolder(liquidityTokenA, msg.sender);
    uint256 fee = feesPerHolder(liquidityTokenA, holderPercent);

    liquidityProvider[liquidityTokenA][msg.sender] -= amount;
    poolBalanceTokenA -= amount;

    bool success = ERC20(liquidityTokenA).transfer(to, amount + fee);
    if(!success) revert();
}

function claimMintedAmount() internal onlyProvider {
    uint256 claimAmount;
    claimAmount = mintedAmount[msg.sender];

    mintedAmount[msg.sender] -= claimAmount;

    bool success = ERC20(kiki).transfer(msg.sender, claimAmount);
    if(!success) revert();
}

function percentPoolHolder(address token, address account) public onlyLiquidityPool view returns (uint256){
    uint256 holderAmount;
    uint256 poolPercent;

    if(token == liquidityTokenA){
        holderAmount = liquidityProvider[liquidityTokenA][account];
        poolPercent = (holderAmount / poolBalanceTokenA) * notation;
    } else {
        holderAmount = liquidityProvider[liquidityTokenB][account];
        poolPercent = (holderAmount / poolBalanceTokenB) * notation;
    }

    return poolPercent;
}

function feesPerHolder(address token, uint256 _percent) public onlyLiquidityPool view returns (uint256){
    uint256 balanceWithFees = ERC20(token).balanceOf(address(this));
    uint256 fees;
    uint256 holderFee;

    if(token == liquidityTokenA){
        fees = balanceWithFees - poolBalanceTokenA;
        holderFee = fees * (_percent / notation);
    } else {
        fees = balanceWithFees - poolBalanceTokenB;
        holderFee = fees * (_percent / notation);
    }

    return holderFee;
}
}
