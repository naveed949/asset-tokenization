pragma solidity ^0.5.0;

// import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
 import "openzeppelin-solidity/contracts/utils/Address.sol";

import "./AssetTokenization.sol";

contract System is Ownable {
  using Address for address;
// (symbol => contractAddress )
mapping( string => address) public tokens;

AssetTokenization public _tokenization;

function tokenize(string calldata name, string calldata symbol, uint256 supply) external onlyOwner returns (bool){
    require(tokens[symbol] == address(0), "Token Symbol already exists");
     _tokenization = new AssetTokenization(name, symbol, supply );
    tokens[symbol] = address(_tokenization);
    emit Tokenization(name, symbol, supply ,address(_tokenization));
    return true;
}
function issueTokens(string calldata symbol, address owner) external onlyOwner returns (bool) {
    require(tokens[symbol] != address(0), "Asset isn't tokenized yet");
    _tokenization = AssetTokenization(tokens[symbol]);
    _tokenization.issue(owner);
    emit Issued(symbol, owner, address(_tokenization));
    return true;
}
function setDocument(bytes32 name, string calldata uri, bytes32 documentHash, string calldata tokenSymbol) external onlyOwner returns(bool){
    require(tokens[tokenSymbol] != address(0), "Token doesn't exists");
     _tokenization = AssetTokenization(tokens[tokenSymbol]);
    _tokenization.setDocument(name,uri,documentHash);
    emit Document(name,uri,documentHash);
    return true;
}
function getTokenContract(string calldata tokenSymbol) external view returns(address){
    return tokens[tokenSymbol];
}

event Tokenization(string name, string symbol, uint256 supply, address indexed contractAddress);
event Document(bytes32 indexed name, string uri, bytes32 documentHash);
event Issued(string symbol, address indexed owner, address indexed contractAddress);
}