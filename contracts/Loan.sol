pragma solidity ^0.4.15;

import "./ERC20Interface.sol";

contract Loan {

    address _lender;

    uint _baseTokenAmount;
    /*uint _minQuoteTokenPrice;*/

    ERC20Interface _baseToken;
    /*Token _quoteToken;*/

    //TODO: add fees, expiration

    function Loan(
            address lender,
            address baseToken,
            address quoteToken,
            uint baseTokenAmount,
            uint minQuoteTokenPrice) {

        _lender = lender;
        _baseToken = ERC20Interface(baseToken);
        /*_quoteToken = ERC20Interface(quoteToken);*/
        _baseTokenAmount = baseTokenAmount;
        /*_minQuoteTokenPrice = minQuoteTokenPrice;*/
    }
}
