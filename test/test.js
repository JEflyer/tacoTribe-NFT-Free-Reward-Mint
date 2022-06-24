const { expect } = require("chai");
const { ethers } = require("hardhat");


let deployer, addr1, addr2, addr3
let minter, Minter
let old, Old

describe("Testing minter exchange", function() {
    beforeEach(async() => {
        [deployer, addr1, addr2, addr3] = await ethers.getSigners();

        old = await ethers.getContractFactory("TacoTribe", deployer)

        Old = await old.deploy(
            "Name",
            "Sym",
            "Init bruv"
        )
        await Old.deployed()

        minter = await ethers.getContractFactory("NewMinter", deployer)

        Minter = await minter.deploy(
            "name",
            "symbol",
            addr1.address,
            Old.address
        )

        await Minter.deployed()

        await Old.connect(deployer).mint(10);

    })

    it("Should allow a conversion to the new minter", async() => {

        await Minter.connect(deployer).mint()

        let tokens = await Minter.connect(deployer).tokensOfOwner(deployer.address)
            // expect(tokens).to.be.equal("[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]");
        console.log(tokens)
    })
});