// SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "KikiV2/LPToken.sol";

pragma solidity 0.8.13;

contract Pool is KikiLP(address(this)) {

constructor (address _liquidityTokenA, address _liquidityTokenB, address _kikiToken) {
    liquidityTokenA = _liquidityTokenA;
    liquidityTokenB = _liquidityTokenB;
    kiki = _kikiToken;
}

modifier onlyProvider() {
    if(!isProvider[liquidityTokenA][msg.sender] && !isProvider[liquidityTokenB][msg.sender]) revert();
    _;
}

modifier onlyProviderTokenA() {
    if(!isProvider[liquidityTokenA][msg.sender]) revert();
    _;
}

mapping(address => mapping(address => uint256)) public liquidityProvider;

mapping(address => mapping(address => uint256)) public mintedAmount;

mapping(address => mapping(address => bool)) public isProvider;

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
    mintedAmount[liquidityTokenA][msg.sender] += amount;
    poolBalanceTokenA += amount;

    isProvider[liquidityTokenA][msg.sender] = true;

    claimMintedAmount(liquidityTokenA);
}

function withdrawTokenA(address to, uint256 amount) public onlyProviderTokenA {
    if(amount == 0) revert();
    if(amount > liquidityProvider[liquidityTokenA][msg.sender]) revert();

    require(ERC20(kiki).transferFrom(msg.sender, address(this), amount));

    KikiLP.burn(msg.sender, amount);

    uint256 holderPercent = poolPercentHolder(liquidityTokenA, msg.sender);
    uint256 fee = feesPerHolder(liquidityTokenA, holderPercent);

    liquidityProvider[liquidityTokenA][msg.sender] -= amount;
    poolBalanceTokenA -= amount;
    
    if(liquidityProvider[liquidityTokenA][msg.sender] == 0){
        isProvider[liquidityTokenA][msg.sender] = false;
    }

    bool success = ERC20(liquidityTokenA).transfer(to, amount + fee);
    if(!success) revert();
}

function claimMintedAmount(address token) internal onlyProvider {
    uint256 claimAmount;

    if(token == liquidityTokenA){
        claimAmount = mintedAmount[liquidityTokenA][msg.sender];
        mintedAmount[liquidityTokenA][msg.sender] -= claimAmount;
    } else {
        claimAmount = mintedAmount[liquidityTokenB][msg.sender];
        mintedAmount[liquidityTokenB][msg.sender] -= claimAmount;
    }

    bool success = ERC20(kiki).transfer(msg.sender, claimAmount);
    if(!success) revert();
}

function poolPercentHolder(address token, address account) public onlyProvider view returns (uint256){
    uint256 holderAmount;
    uint256 percentHolder;

    if(token == liquidityTokenA){
        holderAmount = liquidityProvider[liquidityTokenA][account];
        percentHolder = (holderAmount / poolBalanceTokenA) * notation;
    } else {
        holderAmount = liquidityProvider[liquidityTokenB][account];
        percentHolder = (holderAmount / poolBalanceTokenB) * notation;
    }

    return percentHolder;
}

function feesPerHolder(address token, uint256 _percent) public onlyProvider view returns (uint256){
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
