pragma solidity ^0.5.0;


import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
 import "openzeppelin-solidity/contracts/utils/Address.sol";

import "./AssetTokenization.sol";

contract System is Ownable {
  using Address for address;
// (symbol => contractAddress )
mapping( string => address) public tokens;

AssetTokenization public _tokenization;

  /**
   * @dev Tokenize the asset according to provided details'.
   * @param name Asset's tokens name.
   * @param symbol Token's symbol.
   * @param supply Tokens total supply which need to be created.
   * Requirements:
     *
     * - only contract owner can perform this action
   * @return true in case asset is tokenized.
   */
function tokenize(string calldata name, string calldata symbol, uint256 supply) external onlyOwner returns (bool){
    require(tokens[symbol] == address(0), "Token Symbol already exists");
     _tokenization = new AssetTokenization(name, symbol, supply );
    tokens[symbol] = address(_tokenization);
    emit Tokenization(name, symbol, supply ,address(_tokenization));
    return true;
}

  /**
   * @dev Issue Tokens to given asset owner'.
   * @param symbol Token's symbol.
   * @param owner Account of owner to whom tokens to be issued.
   * Requirements:
     *
     * - only contract owner can perform this action
   * @return true in case tokens issued to owner.
   */
function issueTokens(string calldata symbol, address owner) external onlyOwner returns (bool) {
    require(tokens[symbol] != address(0), "Asset isn't tokenized yet");
    _tokenization = AssetTokenization(tokens[symbol]);
    _tokenization.issue(owner);
    emit Issued(symbol, owner, address(_tokenization));
    return true;
}

  /**
   * @dev Set document to given token's contract'.
   * @param name document name.
   * @param uri document URI where its stored.
   * @param documentHash has of the document.
   * @param tokenSymbol symbol of the token whose document to be set.
   * Requirements:
     *
     * - only contract owner can perform this action
   * @return true in case document is store in asset's contract.
   */
function setDocument(bytes32 name, string calldata uri, bytes32 documentHash, string calldata tokenSymbol) external onlyOwner returns(bool){
    require(tokens[tokenSymbol] != address(0), "Token doesn't exists");
     _tokenization = AssetTokenization(tokens[tokenSymbol]);
    _tokenization.setDocument(name,uri,documentHash);
    emit Document(name,uri,documentHash);
    return true;
}

  /**
   * @dev Get Token's contract address deployed by tokenize function'.
   * @param tokenSymbol symbol of the token whose contract address to return.
   * @return address of token's contract.
   */
function getTokenContract(string calldata tokenSymbol) external view returns(address){
    return tokens[tokenSymbol];
}

event Tokenization(string name, string symbol, uint256 supply, address indexed contractAddress);
event Document(bytes32 indexed name, string uri, bytes32 documentHash);
event Issued(string symbol, address indexed owner, address indexed contractAddress);
}