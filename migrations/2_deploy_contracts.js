var Dogecoin = artifacts.require("./Dogecoin.sol");
var BitcoinCash = artifacts.require("./BitcoinCash.sol");
var Dash = artifacts.require("./Dash.sol");

module.exports = function(deployer) {
  deployer.deploy(Dogecoin);
  deployer.deploy(BitcoinCash);
  deployer.deploy(Dash);
};
