require("dotenv").config();
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	defaultNetwork: "goerli",
	networks: {
		hardhat: {},
		goerli: {
			url: process.env.ALCHEMY_GOERLI_URL,
			accounts: [process.env.DEV_WALLET_PRIVATE_KEY],
		},
	},
	solidity: {
		version: "0.8.9",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	paths: {
		sources: "./contracts",
		tests: "./test",
		cache: "./cache",
		artifacts: "./artifacts",
	},
	mocha: {
		timeout: 40000,
	},
};
