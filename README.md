# Polytope Shared Royalty NFT

Polytope Shared Royalty NFT is a smart contract that allows the creation of NFTs with shared royalties. It is built using Solidity and the OpenZeppelin Contracts library. The royalties are distributed proportionally based on the number of shares each NFT holds.

## Features

- Create NFTs with a custom number of shares.
- Royalties distribution is based on shares held by each NFT.
- Set a minimum and maximum range for shares assigned to each NFT.
- Customizable mint price and total supply.
- Restricted minting to the contract owner or opened for public minting.
- Customizable base URI for metadata.
- Integration with OpenSea's proxy registry for better user experience.
- Reentrancy protection and secure math operations using OpenZeppelin libraries.
- Functions to set custom values for various parameters.
- Events to track royalties distribution and withdrawals.

## Usage

1. Deploy the contract with the required parameters (name, symbol, totalSupply, mintPrice, onlyOwnerCanMint, baseURI, distributionThreshold).
2. Call the `mintTo(address)` function to mint new NFTs with shares. The mint price should be sent along with the transaction.
3. Call the `distributeRoyalties()` function to distribute the collected royalties among NFT holders based on their shares.
4. The contract owner can withdraw the remaining balance by calling the `withdraw()` function.

## Example

```solidity
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PolytopeSharedRoyaltyNFT is ERC721, Ownable, ReentrancyGuard {
    // ...
}
```

## Dependencies

To use this contract, you will need to import the following OpenZeppelin Contracts:

- `@openzeppelin/contracts/token/ERC721/ERC721.sol`
- `@openzeppelin/contracts/access/Ownable.sol`
- `@openzeppelin/contracts/utils/Counters.sol`
- `@openzeppelin/contracts/security/ReentrancyGuard.sol`
- `@openzeppelin/contracts/utils/math/SafeMath.sol`

Make sure to install the OpenZeppelin Contracts library with npm or yarn:

```shell
npm install @openzeppelin/contracts
```

or

```shell
yarn add @openzeppelin/contracts
```

## Customization

You can customize the following parameters while deploying the contract:

- `name`: Name of the NFT collection.
- `symbol`: Symbol of the NFT collection.
- `totalSupply`: The total number of NFTs that can be minted.
- `mintPrice`: The price for minting each NFT (in wei).
- `onlyOwnerCanMint`: If set to true, only the contract owner can mint new NFTs.
- `baseURI`: The base URI for the metadata of the NFTs.
- `distributionThreshold`: The minimum contract balance required to distribute royalties.

After deployment, the contract owner can modify some of these parameters using the following functions:

- `setBaseURI(string)`: Update the base URI for metadata.
- `setMintPrice(uint256)`: Update the mint price.
- `setTotalSupply(uint256)`: Update the total supply.
- `setMinShares(uint256)`: Update the minimum number of shares per NFT.
- `setMaxShares(uint256)`: Update the maximum number of shares per NFT.
- `setProxyRegistryAddress(uint256, address)`: Update the proxy registry address for different networks.
- `setDistributionThreshold(uint256)`: Update the distribution threshold.

## License

This contract is released under the MIT License.
