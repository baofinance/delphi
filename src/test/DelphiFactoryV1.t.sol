// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "../DelphiFactoryV1.sol";

contract DelphiFactoryV1Test is DSTest {
    DelphiFactoryV1 factory;

    function setUp() public {
        address[] memory aggregators = _getLinkAggregators();

        // Create Factory
        factory = new DelphiFactoryV1(aggregators);
        emit log_named_address("Factory", address(factory));
    }

    // -----------------------------
    // ORACLE CREATION
    // -----------------------------

    // Test is pinned to block #14305846
    function testOneVariableOracle() public {
        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle("2xETH", aggregators, expressions));

        assertEq(oracle.getLatestValue(), 6000612530720000000000);
    }

    // Test is pinned to block #14305846
    function testTwoVariableOracle() public {
        uint256[] memory expressions = new uint256[](5);
        // x+y
        expressions[0] = 4;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 1;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle("ETH+BTC", aggregators, expressions));

        assertEq(oracle.getLatestValue(), 47266446265360000000000);
    }

    // Test is pinned to block #14305846
    function testThreeVariableOracle() public {
        uint256[] memory expressions = new uint256[](11);
        // ((x+y)*z) / 1e8
        expressions[0] = 7;
        expressions[1] = 6;
        expressions[2] = 4;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 1;
        expressions[6] = 1;
        expressions[7] = 1;
        expressions[8] = 2;
        expressions[9] = 0;
        expressions[10] = 1e18;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle("(ETH+BTC) / LINK", aggregators, expressions));

        assertEq(oracle.getLatestValue(), 737832013977270330932800);
    }

    function testFailTwoOfAKind() public {
        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy two oracles with the same aggregators/expressions. Should fail.
        DelphiOracleV1(factory.createOracle("2xETH", aggregators, expressions));
        DelphiOracleV1(factory.createOracle("2xETH", aggregators, expressions));
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------

    function testEndorseOracle() public {
        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy two oracles with the same aggregators/expressions. Should fail.
        address oracleAddress = factory.createOracle("2xETH", aggregators, expressions);

        factory.setEndorsed(oracleAddress, true);
        assertTrue(factory.endorsed(oracleAddress));

        factory.setEndorsed(oracleAddress, false);
        assertFalse(factory.endorsed(oracleAddress));
    }

    function testAllowAggregator() public {
        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy two oracles with the same aggregators/expressions. Should fail.
        address oracleAddress = factory.createOracle("2xETH", aggregators, expressions);

        factory.setAllowAggregator(aggregators[0], true);
        assertTrue(factory.linkAggregators()[aggregators[0]]);

        factory.setAllowAggregator(aggregators[0], false);
        assertTrue(factory.linkAggregators()[aggregators[0]]);
    }

    // -----------------------------
    // HELPER FUNCTIONS
    // -----------------------------

    // Helper function to get link oracles in form of address[] memory
    function _getLinkAggregators() private pure returns (address[] memory linkAggregators) {
        linkAggregators = new address[](3);
        linkAggregators[0] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD -> x
        linkAggregators[1] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // BTC/USD -> y
        linkAggregators[2] = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c; // LINK/USD -> z
        // aggregators[0] = 0x47E1e89570689c13E723819bf633548d611D630C; // BTC Marketcap USD
        // aggregators[1] = 0xAA2FE1324b84981832AafCf7Dc6E6Fe6cF124283; // ETH Marketcap USD
    }
}
