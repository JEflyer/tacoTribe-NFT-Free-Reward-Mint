//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

//import ERC721AQueryable
import "./ERC721A/ERC721AQueryable.sol";

//import ERC721 interface
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//import reentrancy guard
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//import interface for old minter#
import "./interfaces/IOld.sol";

//import hardhat console.log()
// import "hardhat/console.sol";

contract NewMinter is ERC721AQueryable, ReentrancyGuard {
    address private admin;

    mapping(uint256 => bool) private tokensMinted;

    //Stores a string of the base URI
    //This variable is private because it is not needed to be retreived outside this contract directly
    string private baseURI;

    //Stores whether minting is paused
    //This variable is public because it will need to be retreived outside this contract
    bool public paused;

    IOld private oldMinter;

    constructor(
        string memory _name,
        string memory _symbol,
        address _admin,
        address _old
    ) ERC721A(_name, _symbol) {
        admin = _admin;

        oldMinter = IOld(_old);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "ERR:NA"); //NA => Not Admin
        _;
    }

    function setBaseURI(string memory base) external onlyAdmin {
        require(bytes(base).length != 0, "ERR:ES"); //EX=> Empty String
        baseURI = base;
    }

    function setPause(bool _state) external onlyAdmin {
        paused = _state;
    }

    //This function is a function in the ERC721A inherited contract
    //We override it so we can set a custom variable
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI; //put baseURI in here
    }

    function mint() external nonReentrant {
        require(!paused, "ERR:CP"); //CP => Currently Paused

        //get the tokens that the caller owns
        uint256[] memory tokens = oldMinter.walletOfOwner(_msgSender());

        uint16 counter;

        // console.log(tokens);

        //find out what tokens out of that array have already been minted in this contract
        for (uint16 i = 0; i < tokens.length; ) {
            if (tokensMinted[tokens[i]] == false) {
                tokensMinted[tokens[i]] = true;
                unchecked {
                    counter++;
                }
            }

            unchecked {
                i++;
            }
        }

        // console.log(counter);

        //mint the remaining tokens for caller
        _safeMint(msg.sender, counter);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
}
