const TokenHouse = artifacts.require("TokenHouse");
module.exports = async function (deployer) {
  await deployer.deploy(TokenHouse);
};
