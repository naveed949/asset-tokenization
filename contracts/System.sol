pragma solidity ^0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

import "./Tokenization.sol";

contract System is Ownable {
    using Address for address;
// (symbol => contractAddress )
mapping( string => address) public tokens;

Tokenization private tokenization;

function createToken(string calldata name, string calldata symbol, uint256 supply, address owner) external onlyOwner returns (bool){
    require(tokens[symbol] == address(0), "Token Symbol already exists");
     tokenization = new Tokenization(name, symbol, supply, owner );
    tokens[symbol] = address(tokenization);
    emit Tokenization(symbol,owner,supply,address(tokenization));
    return true;
}
function setDocument(bytes32 name, string calldata uri, bytes32 documentHash, string calldata tokenSymbol) external onlyOwner returns(bool){
    require(tokens[tokenSymbol] != address(0), "Token doesn't exists");
     tokenization = Tokenization(tokens[tokenSymbol]);
    tokenization.setDocument(name,uri,documentHash);
    return true;
}
function getTokenContract(string calldata tokenSymbol) external view returns(address){
    return tokens[tokenSymbol];
}

event Tokenization(string indexed symbol, address indexed owner, uint256 indexed amount, address indexed contractAddress);
}