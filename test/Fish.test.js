const { expect } = require("chai");
const { ethers } = require("hardhat");
const Web3 = require("web3");

let web3, fishToken, owner, john, angela;

describe("Fish", function () {
	before(async () => {
		web3 = new Web3();
		BN = web3.utils.BN;
		[owner, john, angela] = await ethers.getSigners();
		const Fish = await ethers.getContractFactory("Fish");
		fishToken = await Fish.deploy();

		await fishToken.deployed();
	});

	describe("Deployment", function () {
		it("Should set the right owner", async function () {
			expect(await fishToken.owner()).to.equal(owner.address);
		});
	});

	describe("NFT Mint and Transfers", function () {
		describe("Premint", function () {
			it("Perform 100 NFT give away and perform it only once", async function () {
				const giveAwayAmount = 100;
				await fishToken.connect(owner).giveAway();
				await expect(await fishToken.totalSupply()).to.equal(giveAwayAmount);
			});
			it("You cannot give away more than once", async function () {
				await expect(fishToken.connect(owner).giveAway()).to.be.revertedWith(
					"Airdrop already performed.",
				);
			});
		});

		describe("Mint", function () {
			it("John mints 10 tokens", async function () {
				const mintCount = 10;

				await fishToken.connect(john).mint(mintCount, {
					value: BigInt(await web3.utils.toWei("1")) * BigInt(mintCount),
				});

				await expect(await fishToken.balanceOf(john.address)).to.equal(mintCount);
			});
			it("Angela tries minting 2 tokens with 1 ether", async function () {
				const mintCount = 2;

				await expect(
					fishToken.connect(angela).mint(mintCount, {
						value: BigInt(await web3.utils.toWei("1")),
					}),
				).to.be.revertedWith("Insufficient funds in the wallet");

				await expect(await fishToken.balanceOf(angela.address)).to.equal(0);
			});
			it("Angela tries minting 21 tokens", async function () {
				const mintCount = 21;

				await expect(
					fishToken.connect(angela).mint(mintCount, {
						value: BigInt(await web3.utils.toWei("1")) * BigInt(mintCount),
					}),
				).to.be.revertedWith("Invalid amount");

				await expect(await fishToken.balanceOf(angela.address)).to.equal(0);
			});
			it("John tries minting 11 more tokens to mint over 20 tokens", async function () {
				const mintCount = 11;
				await expect(
					fishToken.connect(john).mint(mintCount, {
						value: BigInt(await web3.utils.toWei("1")) * BigInt(mintCount),
					}),
				).to.be.revertedWith("Maximum amount per wallet already minted for this phase");
			});
		});

		describe("Post Mint", function () {});
	});
});
