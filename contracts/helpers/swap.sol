// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "hardhat/console.sol";


contract Swap {
    IUniswapV2Router02 public immutable uniswapRouter;
    IERC20 public DAI;

    constructor(IUniswapV2Router02 router, address DAI_) public {
        uniswapRouter = router;
        DAI = IERC20(DAI_);
    }

    function convertEthToDai(uint256 daiAmount, uint256 deadline)
        public
        payable
    {
        // uint256 deadline = block.timestamp + 15;
        // using 'now' for convenience, for mainnet pass deadline from frontend!

        require(deadline > block.timestamp + 100000, "Swap: invalid deadline");
        console.log(deadline);
        console.log(block.timestamp);

        uint256[] memory amounts =
            uniswapRouter.swapETHForExactTokens{value: msg.value}(
                daiAmount,
                getPathForETHtoDAI(),
                address(this),
                deadline
            );

        console.log(amounts[0]);
        console.log(amounts[1]);
        console.log(address(this).balance);

        // refund leftover ETH to user
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        console.log(address(this).balance);

        require(success, "Swap: refund failed");
    }

    function getEstimatedETHforDAI(uint256 daiAmount)
        public
        view
        returns (uint256[] memory)
    {
        return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoDAI());
    }

    function getPathForETHtoDAI() private view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH();
        path[1] = address(DAI);

        return path;
    }

    // important to receive ETH
    receive() external payable {}
}
