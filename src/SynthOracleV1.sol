// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@chainlink/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/proxy/utils/Initializable.sol";
import "./math/Equation.sol";

contract SynthOracleV1 is Initializable, AggregatorV3Interface {

    address public factory;
    AggregatorV3Interface[] public oracles;
    Equation.Node[] public nodes;

    constructor () {
        // unused
    }

    // -----------------------------
    // PUBLIC FUNCTIONS
    // -----------------------------

    /**
     * Initialize the Oracle
     *
     * @param _factory Address of this contract's CREATE2 factory
     * @param _oracles ChainLink aggregators to use in performOperation()
     */
    function init(address _factory, address[] memory _oracles, uint256[] calldata _expressions) external initializer {
        // Set factory & ChainLink aggregators
        factory = _factory;
        for (int i = 0; i < _oracles.length; i++) {
            oracles[i] = AggregatorV3Interface(_oracles[i]);
        }

        // Set up equation for performOperation
        Equation.init(nodes, _expressions);
    }

    /**
     * Performs a special operation with data from available oracles
     */
    function getLatestValue() external view returns (int256) {
        (,int256 xValue,,,) = oracles[0].latestRoundData();
        uint256 yValue;
        uint256 zValue;
        if (oracles.length >= 2) {
            (,yValue,,,) = oracles[1].latestRoundData();
        }
        if (oracles.length == 3) {
            (,zValue,,,) = oracles[2].latestRoundData();
        }

        return Equation.calculate(nodes, price);
    }

    /**
     * Get the latest value of the oracle (performOperation remap to work with AggregatorV3Interface)
     */
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        // TODO: Need to figure out what to set these to
        roundId = 0;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;

        // Set oracle price to oracle operation
        answer = performOperation();
    }
}