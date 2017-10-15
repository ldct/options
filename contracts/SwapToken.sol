pragma solidity ^0.4.15;

import "./TokenizedSwap.sol";
import "./ERC20Interface.sol";

contract SwapToken is ERC20Interface {
	uint8 public constant decimals = 18;
	uint256 _totalSupply = 0;

	mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) allowed;

    address _collateralCoinAddress;
    address _strikeCoinAddress;
    uint _ratioStrike;
    uint _ratioCollateral;
    uint _expiry;

    // Constructor
    function SwapToken(
            address collateralCoinAddress,
            address strikeCoinAddress,
            uint ratioStrike,
            uint ratioCollateral,
            uint expiry) {
        _collateralCoinAddress = collateralCoinAddress;
        _strikeCoinAddress = strikeCoinAddress;
        _ratioStrike = ratioStrike;
        _ratioCollateral = ratioCollateral;
        _expiry = expiry;
    }

    function issue(uint strikeAmount) {
        uint collateralAmount = strikeAmount * _ratioCollateral / _ratioStrike;
        TokenizedSwap ts = new TokenizedSwap(
            msg.sender,
            _collateralCoinAddress,
            _strikeCoinAddress,
            this,
            strikeAmount,
            collateralAmount,
            strikeAmount * 1000,
            _expiry
        );

        balances[msg.sender] += strikeAmount * 1000;

        ERC20Interface collateralCoin = ERC20Interface(_collateralCoinAddress);
        collateralCoin.transferFrom(msg.sender, this, collateralAmount);

    }


    function totalSupply() constant returns (uint256 supply) {
        return _totalSupply - balanceOf(0);
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

	// Triggered when tokens are transferred.
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	// Triggered whenever approve(address _spender, uint256 _value) is called.
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}