pragma solidity ^0.4.15;

import "./ERC20Interface.sol";

contract Order {

    address _maker;

    ERC20Interface _makerToken;
    ERC20Interface _takerToken;

    uint _makerTokenAmount;
    uint _pricePerMakerToken; //price of maker token in taker token

    bool valid = true;

    function Order(
            address maker,
            address makerToken,
            address takerToken,
            uint makerTokenAmount,
            uint pricePerMakerToken) {

        _maker = maker;
        _makerTokenAmount = makerTokenAmount;
        _pricePerMakerToken = pricePerMakerToken;

        _makerToken = ERC20Interface(makerToken);
        _takerToken = ERC20Interface(takerToken);
    }

    function cancel() {
      require(msg.sender == _maker);
      valid = false;
    }

    function fill() {
      require(msg.sender != _maker);
      require(_makerToken.transferFrom(this, msg.sender, _makerTokenAmount));
      require(_takerToken.transferFrom(msg.sender, this,
        _pricePerMakerToken * _makerTokenAmount));
    }
}
