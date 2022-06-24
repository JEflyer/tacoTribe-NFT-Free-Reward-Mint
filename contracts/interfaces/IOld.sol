pragma solidity 0.8.15;

interface IOld {
    function walletOfOwner(address _query)
        external
        view
        returns (uint256[] memory);
}
