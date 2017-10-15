pragma solidity ^0.4.15;

import "./ERC20Interface.sol";
import "./Exchange.sol";

contract ShortSell {

    address _lender;

    // Loan contract
    Token _loanContract;

    uint _baseTokenAmount;
    uint _minQuoteTokenPrice;

    Token _baseToken;
    Token _quoteToken;

    function ShortSell(
            address lender,
            address loanContract,
            address buyContract,
            uint baseTokenAmount,
            uint minQuoteTokenPrice) {

        require(loanContract._baseToken == buyContract._makerToken);
        require(loanContract._baseTokenAmount <= buyContract._makerTokenAmount);

        _lender = lender;
        _loanContract = Exchange.Order(loanContract);
        _buyContract = Exchange.Order(buyContract);

        _baseTokenAmount = baseTokenAmount;
        _minQuoteTokenPrice = minQuoteTokenPrice;

        _baseToken = ERC20Interface();
        _quoteToken = ERC20Interface(loanContract.takerToken);
    }

    function close(address sellContract) {
    }
}
