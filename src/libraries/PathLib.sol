// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library PathLib {
    function buildPath(address a, address b) internal pure returns (address[] memory path) {
        path = new address[](2);
        address;
        path[0] = a;
        path[1] = b;

        return path;
    }
}
