pragma solidity ^0.4.15;

import "./ERC20Interface.sol";
import "./Order.sol";

contract ShortSell {

    address _lender;

    // Loan contract
    Order _loanContract;
    Order _buyContract;

    uint _baseTokenAmount;
    uint _minQuoteTokenPrice;

    ERC20Interface _baseToken;
    ERC20Interface _quoteToken;

    function ShortSell(
            address lender,
            address loanContract,
            address buyContract,
            address baseToken,
            address quoteToken,
            uint baseTokenAmount,
            uint minQuoteTokenPrice) {

        /*require(loanContract._baseToken == buyContract._makerToken);
        require(loanContract._baseTokenAmount <= buyContract._makerTokenAmount);*/

        _lender = lender;
        _loanContract = Order(loanContract);
        _buyContract = Order(buyContract);

        _baseTokenAmount = baseTokenAmount;
        _minQuoteTokenPrice = minQuoteTokenPrice;

        _baseToken = ERC20Interface(baseToken);
        _quoteToken = ERC20Interface(quoteToken);
    }

    function close(address sellContract) {
    }
}
