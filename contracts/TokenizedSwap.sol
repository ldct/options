pragma solidity ^0.4.15;

import "./ERC20Interface.sol";
import "./Swap.sol";

// Like OTCSwap, except anyone with rightsToken can burn it to call strike()

contract TokenizedSwap {

    address _writer;
    address _striker;

    uint _collateralAmount;
    uint _strikeAmount;
    uint _rightsAmount;

    uint _expiry;

    ERC20Interface collateralCoin;
    ERC20Interface strikeCoin;
    ERC20Interface rightsToken;

    function TokenizedSwap(
            address writer,
            address collateralCoinAddress,
            address strikeCoinAddress,
            address rightsTokenAddress,
            uint strikeAmount,
            uint collateralAmount,
            uint rightsAmount,
            uint expiry) {

        _writer = writer;
        _collateralAmount = collateralAmount;
        _strikeAmount = strikeAmount;
        _expiry = expiry;
        _rightsAmount = rightsAmount;

        collateralCoin = ERC20Interface(collateralCoinAddress);
        strikeCoin = ERC20Interface(strikeCoinAddress);
        rightsToken = ERC20Interface(rightsTokenAddress);

    }

    function owner() constant returns (address) {
        return _writer;
    }

    function collateralize() {
        require(msg.sender == _writer);
        // take ownership of collateral
        require(collateralCoin.transferFrom(_writer, this, _collateralAmount));
    }

    function strike() {
        // send collateral to striker
        require(collateralCoin.transfer(msg.sender, _collateralAmount));
        // collect strike fee from striker
        require(strikeCoin.transferFrom(msg.sender, this, _strikeAmount));
        // send strike fee to to writer
        require(strikeCoin.transfer(_writer, _strikeAmount));

        // burn sender rightsToken
        require(rightsToken.transferFrom(msg.sender, this, _rightsAmount));
        require(rightsToken.transfer(0, _rightsAmount));
    }

}