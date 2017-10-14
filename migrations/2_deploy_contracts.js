var Dogecoin = artifacts.require("./Dogecoin.sol");
var BitcoinCash = artifacts.require("./BitcoinCash.sol");

module.exports = function(deployer) {
  deployer.deploy(Dogecoin);
  deployer.deploy(BitcoinCash);
};
