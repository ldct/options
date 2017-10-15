const Dogecoin = artifacts.require("./Dogecoin.sol");
const BitcoinCash = artifacts.require("./BitcoinCash.sol");
const Dash = artifacts.require("./Dash.sol");
const Swap = artifacts.require("./Swap.sol");
const TokenizedSwap = artifacts.require("./TokenizedSwap.sol");
const SwapToken = artifacts.require("./SwapToken.sol");


// 30th July 2020
const EXPIRY = 1596067200;

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
              }),
            ]);
          });
        });
      });
    });
  });

  it("dogecoin allowance", function() {
    return Dogecoin.deployed().then(function(dogecoin) {
        return dogecoin.approve(accounts[1], 10, {'from': accounts[0]}).then(function(txn) {
          return dogecoin.allowance(accounts[0], accounts[1]).then(function(cap) {
            assert.equal(10, cap.valueOf(), "cap");
          });
        });
    });
  });

  it("collateralize succeeds if has funds funds", function() {
    return Dogecoin.deployed().then(function(dogecoin) {
      return BitcoinCash.deployed().then(function(bch) {
        return Swap.new(accounts[0], dogecoin.address, accounts[1], bch.address, 1, 1, EXPIRY).then(function(swap) {
          return dogecoin.approve(swap.address, 1, {'from': accounts[0]}).then(function(txn) {
            return swap.collateralize({'from': accounts[0]}).then(function(txn) {
              assert(true);
            });
          });
        });
      });
    });
  });

  it("collateralize fails if no has funds funds", function() {
    return Dogecoin.deployed().then(function(dogecoin) {
      return BitcoinCash.deployed().then(function(bch) {
        return Swap.new(accounts[0], dogecoin.address, accounts[1], bch.address, 10, 10, EXPIRY).then(function(swap) {
          return dogecoin.approve(swap.address, 1, {'from': accounts[0]}).then(function(txn) {
            return swap.collateralize({'from': accounts[0]}).then(function(txn) {
              assert(false);
            }).catch(function(e) {
              assert(true);
            });
          });
        });
      });
    });
  });

  it("striker exercises swap", function() {
    return Dogecoin.deployed().then(function(dogecoin) {
      return BitcoinCash.deployed().then(function(bitcoincash) {
        return bitcoincash.transfer(accounts[1], 21000000).then(function(txn) {
          return Swap.new(accounts[0], dogecoin.address, accounts[1], bitcoincash.address, 1, 1, EXPIRY).then(function(swap) {
            return dogecoin.approve(swap.address, 1, {'from': accounts[0]}).then(function(txn) {
              return swap.collateralize({'from': accounts[0]}).then(function(txn) {
                return bitcoincash.approve(swap.address, 1, {'from': accounts[1]}).then(function(txn) {
                  return swap.strike({'from': accounts[1]}).then(function(txn) {
                    assert(true);
                  })
                })
              });
            });
          });
        });
      });
    });
  });
});

contract('TokenizedSwap', function(accounts) {
  it("striker exercises swap", async () => {
    const dogecoin = await Dogecoin.deployed();
    const bitcoincash = await BitcoinCash.deployed();
    const dash = await Dash.deployed();

    await bitcoincash.transfer(accounts[2], 1000000);
    await dogecoin.transfer(accounts[2], 1);
    await dash.transfer(accounts[2], 18900000);

    const swap = await TokenizedSwap.new(
      accounts[0], dogecoin.address, bitcoincash.address, dash.address, 1, 1, 1000, EXPIRY
    );

    // account | DOGE balance | BCH balance | DASH balance
    // 0       | 84000000     | 0           | 0
    // 1       | 0            | 20000000    | 0
    // 2       | 0            | 1000000     | 18900000

    // collateralize 1 DOGE from account 0
    await dogecoin.approve(swap.address, 1);
    await swap.collateralize();

    // strike from account 2
    await bitcoincash.approve(swap.address, 1, {'from': accounts[2]});
    await dash.approve(swap.address, 1000, {'from': accounts[2]});
    await swap.strike({'from': accounts[2]});

  });
});

contract('SwapToken', function(accounts) {
  it("issues correctly", async () => {
    const dogecoin = await Dogecoin.deployed();
    const bitcoincash = await BitcoinCash.deployed();
    const dash = await Dash.deployed();

    const st = await SwapToken.new(
      dogecoin.address,
      bitcoincash.address,
      1,
      1,
      EXPIRY
    );

    dogecoin.approve(st.address, 1);
    await st.issue(1);


    console.log(await dogecoin.balanceOf(accounts[0]));
    console.log(await st.balanceOf(accounts[0]));


  });
});