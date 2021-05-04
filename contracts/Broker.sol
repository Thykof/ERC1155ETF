// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

import "@openzeppelin/contracts/access/Ownable.sol";

import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol";

import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@uniswap/lib/contracts/libraries/FixedPoint.sol";

import "hardhat/console.sol";

contract Broker is Ownable {
    using SafeMath for uint256;

    address public immutable factory;
    IUniswapV2Router02 public router;
    IERC20 DAI;

    // accounts to token address to amount
    mapping(address => mapping(address => uint256)) public balances;

    mapping(uint256 => ETF) private ETFs;

    struct ETF {
        address[] tokens;
        uint256[] ratios;
    }

    constructor(IUniswapV2Router02 router_, address DAI_) public {
        router = router_;
        factory = router.factory();
        DAI = IERC20(DAI_);

        address[] memory tokens = new address[](1);
        tokens[0] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
        uint256[] memory ratios = new uint256[](1);
        ratios[0] = 80; // 80% WETH, 20% DAI
        ETFs[1] = ETF({tokens: tokens, ratios: ratios});
    }

    function getETF(uint256 tokenId, uint256 index)
        public
        view
        returns (address token, uint256 ratio)
    {
        token = ETFs[tokenId].tokens[index];
        ratio = ETFs[tokenId].ratios[index];
    }

    function buyShares(uint256 amountDAI, uint256 tokenId) public {
        require(amountDAI >= 10**uint256(DAI.decimals()), "Broker: bad amount");

        // 1 share = 1 DAI
        TransferHelper.safeTransferFrom(
            address(DAI),
            msg.sender,
            address(this),
            amountDAI
        );

        for (uint256 index = 0; index < ETFs[tokenId].tokens.length; index++) {
            address tokenB = ETFs[tokenId].tokens[index];
            uint256 amount = (ETFs[tokenId].ratios[index] / 100) * amountDAI;

            swapBuy(amount, getAmountOutMin(amount, tokenB), tokenB);
        }
    }

    function sellSahres(uint256 amount, uint256 tokenId) public {}

    function swapBuy(
        uint256 amount,
        uint256 amountOutMin,
        address tokenB
    ) internal {
        TransferHelper.safeApprove(address(DAI), address(router), amount);

        address[] memory path = new address[](2);
        path[0] = address(DAI);
        path[1] = tokenB;
        router.swapExactTokensForTokens(
            amount,
            amountOutMin,
            path,
            msg.sender,
            block.timestamp
        );
    }

    function swapSell(uint256 amount) internal {}

    function getAmountOutMin(uint256 amount, address tokenB)
        internal
        returns (uint256)
    {
        uint256 price = getPriceFromOracle(tokenB);
    }

    function getPriceFromOracle(address tokenB)
        internal
        view
        returns (uint256)
    {
        IUniswapV2Pair pair =
            IUniswapV2Pair(
                UniswapV2Library.pairFor(factory, address(DAI), tokenB)
            );
        (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        ) = UniswapV2OracleLibrary.currentCumulativePrices(address(pair));

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        FixedPoint.uq112x112 memory price0Average =
            FixedPoint.uq112x112(
                uint224((price0Cumulative - pair.price0CumulativeLast()) / now)
            );
        FixedPoint.uq112x112 memory price1Average =
            FixedPoint.uq112x112(
                uint224((price1Cumulative - pair.price1CumulativeLast()) / now)
            );

        return price0Average._x; // TODO: or price1Average
    }
}
