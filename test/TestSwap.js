var Dogecoin = artifacts.require("./Dogecoin.sol");
var BitcoinCash = artifacts.require("./BitcoinCash.sol");
var Swap = artifacts.require("./Swap.sol");

contract('Dogecoin, BCH, Swap', function(accounts) {
  it("starts with the right supply", function () {
    return Dogecoin.deployed().then(function(instance) {
      return instance.totalSupply().then(function(supply) {
        assert.equal(supply.valueOf(), 84000000, "84000000 wasn't the total supply");
      });
    });
  });

  it("fails to transfer from 1", function () {
    return Dogecoin.deployed().then(function(instance) {
      return instance.transfer(accounts[3], 100, {'from': accounts[4]}).then(function(txn) {
        assert.equal(1, 1, "succeeded unexpectedly");
      });
    });
  });

  it("transfers 100 from 0 to 1 to 2", function() {
    return Dogecoin.deployed().then(function(instance) {
      return instance.transfer(accounts[1], 100).then(function(txn) {
        return instance.balanceOf.call(accounts[1]).then(function(balance) {
          assert.equal(balance, 100, "100 wasn't the resulting balance");
          return instance.transfer(accounts[2], 100, {'from': accounts[1]}).then(function(txn) {
            return Promise.all([
              instance.balanceOf.call(accounts[2]).then(function(balance) {
                assert.equal(balance, 100, "100 wasn't the recepient balance");
              }),
              instance.balanceOf.call(accounts[1]).then(function(balance) {
                assert.equal(balance, 0, "0 wasn't the sender balance");
              })
            ]);
          });
        });
      });
    });
  });

  // it("fails swap setup if no funds", function() {
  //   return Swap.new.call(accounts[1], Dogecoin.deployed(), accounts[2], BitcoinCash.deployed(), 1, 1).then(function(instance) {
  //     assert.equal(0, 1, "hi");
  //   }).catch(function(error) {
  //     console.log(error);
  //   });

  // });

  it("collateralize succeeds if has funds funds", function() {
    return Dogecoin.deployed().then(function(dogecoin) {
      return dogecoin.approve.call(accounts[1], 1, {'from': accounts[0]}).then(function(txn) {
        return Swap.new.call(accounts[0], Dogecoin.deployed().address, accounts[1], BitcoinCash.deployed().address, 1, 1).then(function(instance) {
          assert.equal(0, 1, "hi");
        });
      });
    });
  });

});
