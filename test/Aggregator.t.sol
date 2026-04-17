// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/DexAggregator.sol";
import "../src/adapters/V2Adapter.sol";
import "../src/adapters/V3Adapter.sol";

contract AggregatorTest is Test {
    DexAggregator public agg;
    V2Adapter public v2;
    V3Adapter public v3;

    address USER = address(1);

    // Sepolia tokens
    address WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    address USDC = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238;

    // Routers
    address V2_ROUTER = 0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3;
    address V3_ROUTER = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address V3_QUOTER = 0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3;

    function setUp() public {
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));

        // deploy adapters
        v2 = new V2Adapter(V2_ROUTER);
        v3 = new V3Adapter(V3_ROUTER, V3_QUOTER);

        // deploy aggregator
        agg = new DexAggregator();
        agg.initialize(address(v2), address(v3));

        vm.makePersistent(address(v2));
        vm.makePersistent(address(v3));
        vm.makePersistent(address(agg));

        // give USER some WETH
        deal(WETH, USER, 10 ether);

        vm.startPrank(USER);
        IERC20(WETH).approve(address(agg), type(uint256).max);
        vm.stopPrank();
    }

    function test_GetBestQuote() public {
        (uint out,,) = agg.getBestQuote(WETH, USDC, 1 ether);
        assertGt(out, 0);
    }

    function test_Swap() public {
        vm.startPrank(USER);

        uint balanceBefore = IERC20(USDC).balanceOf(USER);

        uint out = agg.swap(
            WETH,
            USDC,
            1 ether,
            0 // no slippage protection for test
        );

        uint balanceAfter = IERC20(USDC).balanceOf(USER);

        assertGt(out, 0);
        assertGt(balanceAfter, balanceBefore);

        vm.stopPrank();
    }

    function test_RevertZeroAmount() public {
        vm.startPrank(USER);

        vm.expectRevert();
        agg.swap(WETH, USDC, 0, 0);

        vm.stopPrank();
    }

    function test_RevertSameToken() public {
        vm.startPrank(USER);

        vm.expectRevert();
        agg.swap(WETH, WETH, 1 ether, 0);

        vm.stopPrank();
    }

    function test_RevertPaused() public {
        agg.setPaused(true);

        vm.startPrank(USER);

        vm.expectRevert();
        agg.swap(WETH, USDC, 1 ether, 0);

        vm.stopPrank();
    }

    function test_RouteSelection() public {
        (uint v2Out,) = _v2Quote(1 ether);
        (uint v3Out,) = _v3Quote(1 ether);

        (uint best,,) = agg.getBestQuote(WETH, USDC, 1 ether);

        uint expected = v3Out > v2Out ? v3Out : v2Out;

        assertEq(best, expected);
    }

    function _v2Quote(uint amount)
        internal
        returns (uint out, bool ok)
    {
        try v2.quote(WETH, USDC, amount) returns (uint o) {
            return (o, true);
        } catch {
            return (0, false);
        }
    }

    function _v3Quote(uint amount)
        internal
        returns (uint out, bool ok)
    {
        try v3.quoteBest(WETH, USDC, amount) returns (uint o, uint24) {
            return (o, true);
        } catch {
            return (0, false);
        }
    }
}