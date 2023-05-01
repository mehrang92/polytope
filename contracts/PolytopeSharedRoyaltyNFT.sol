// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract PolytopeSharedRoyaltyNFT is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    Counters.Counter private _nextTokenId;

    uint256 public TOTAL_SUPPLY;
    uint256 public MINT_PRICE;
    bool public ONLY_OWNER_CAN_MINT;
    string private _customBaseURI;

    uint256 public minShares = 500;
    uint256 public maxShares = 1000;

    mapping(uint256 => uint256) public tokenShares;
    uint256 public totalShares;

    uint256 public distributionThreshold;

    // OpenSea proxy registry addresses for different networks
    mapping(uint256 => address) private proxyRegistryAddresses;

    // Events
    event RoyaltiesDistributed(uint256 amount);
    event Withdrawn(uint256 amount);

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint256 mintPrice,
        bool onlyOwnerCanMint,
        string memory baseURI,
        uint256 _distributionThreshold
    ) ERC721(name, symbol) {
        TOTAL_SUPPLY = totalSupply;
        MINT_PRICE = mintPrice;
        ONLY_OWNER_CAN_MINT = onlyOwnerCanMint;
        _customBaseURI = baseURI;
        distributionThreshold = _distributionThreshold;

        // Initialize OpenSea proxy registry addresses
        // Add other networks as required
        proxyRegistryAddresses[1] = 0xa5409ec958C83C3f309868babACA7c86DCB077c1; // Ethereum mainnet
        proxyRegistryAddresses[4] = 0xF57B2c51dED3A29e6891aba85459d600256Cf317; // Ethereum rinkeby
        proxyRegistryAddresses[
            137
        ] = 0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101; // Polygon mainnet
        proxyRegistryAddresses[
            80001
        ] = 0x207Fa8Df3a17D96Ca7EA4f2893fcdCb78a304101; // Polygon mumbai
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _customBaseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _customBaseURI = baseURI_;
    }

    function setMintPrice(uint256 mintPrice_) public onlyOwner {
        MINT_PRICE = mintPrice_;
    }

    function setTotalSupply(uint256 totalSupply_) public onlyOwner {
        require(
            totalSupply_ >= _nextTokenId.current(),
            "New total supply should be greater than or equal to the current number of minted tokens"
        );
        TOTAL_SUPPLY = totalSupply_;
    }

    function setMinShares(uint256 newMinShares) public onlyOwner {
        require(
            newMinShares < maxShares,
            "Minimum shares should be less than maximum shares"
        );
        minShares = newMinShares;
    }

    function setMaxShares(uint256 newMaxShares) public onlyOwner {
        require(
            newMaxShares > minShares,
            "Maximum shares should be greater than minimum shares"
        );
        maxShares = newMaxShares;
    }

    function setProxyRegistryAddress(
        uint256 network,
        address proxyRegistryAddress
    ) public onlyOwner {
        proxyRegistryAddresses[network] = proxyRegistryAddress;
    }

    function mintTo(address to) public payable nonReentrant returns (uint256) {
        require(
            !ONLY_OWNER_CAN_MINT ||
                (ONLY_OWNER_CAN_MINT && _msgSender() == owner()),
            "Minting restricted to owner"
        );

        uint256 tokenId = _nextTokenId.current();
        require(tokenId < TOTAL_SUPPLY, "Max supply reached");
        require(
            msg.value >= MINT_PRICE,
            "Transaction value did not equal the mint price"
        );

        uint256 shares = randomShares();
        tokenShares[tokenId] = shares;
        totalShares += shares;

        // Mint
        uint256 currentTokenId = _nextTokenId.current();
        _nextTokenId.increment();
        _safeMint(to, currentTokenId);
        return currentTokenId;
    }

    function randomShares() private view returns (uint256) {
        return
            minShares +
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % (maxShares - minShares + 1));
    }

    function distributeRoyalties() public nonReentrant {
        uint256 contractBalance = address(this).balance;

        require(
            contractBalance >= distributionThreshold,
            "Not enough balance to distribute"
        );

        for (uint256 i = 0; i < _nextTokenId.current(); i++) {
            address tokenOwner = ownerOf(i);
            uint256 shareAmount = (tokenShares[i] * contractBalance) /
                totalShares;
            payable(tokenOwner).transfer(shareAmount);
        }

        emit RoyaltiesDistributed(contractBalance);
    }

    function withdraw() public onlyOwner {
        uint256 contractBalance = address(this).balance;
        payable(owner()).transfer(contractBalance);

        emit Withdrawn(contractBalance);
    }

    function setDistributionThreshold(uint256 newThreshold) public onlyOwner {
        distributionThreshold = newThreshold;
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        // If the operator is OpenSea's proxy registry, return true
        if (proxyRegistryAddresses[block.chainid] == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    receive() external payable {}
}
