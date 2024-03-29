pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

contract AssetTokenization is IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

  string internal _name;
  string internal _symbol;
  uint256 internal _totalSupply;
  uint8 internal _decimals;

  // Mapping from tokenHolder to balance.
  mapping(address => uint256) internal _balances;

  // Mapping from (tokenHolder, spender) to allowed value.
  mapping (address => mapping (address => uint256)) internal _allowed;

    struct Doc {
    string docURI;
    bytes32 docHash;
  }
  // Mapping for token URIs.
  mapping(bytes32 => Doc) internal _documents;



    constructor(
    string memory name,
    string memory symbol,
    uint256 totalSupply
  )
    public
  {
   _name = name;
   _symbol = symbol;
   _decimals = 18;

   _totalSupply = totalSupply * (uint256(10) ** _decimals);
  }
    /**
   * @dev Get the name of the token, e.g., "MyToken".
   * @return Name of the token.
   */
  function name() external view returns(string memory) {
    return _name;
  }
  /**
   * @dev Get the symbol of the token, e.g., "MYT".
   * @return Symbol of the token.
   */
  function symbol() external view returns(string memory) {
    return _symbol;
  }

 /**
   * @dev Get the decimals
   * @return decimals of the token.
   */
  function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
   * @dev Get the total number of issued tokens.
   * @return Total supply of tokens currently in circulation.
   */
  function totalSupply() external view   returns (uint256) {
    return _totalSupply;
  }
  /**
   * @dev Get the balance of the account with address 'tokenHolder'.
   * @param tokenHolder Address for which the balance is returned.
   * @return Amount of token held by 'tokenHolder' in the token contract.
   */
  function balanceOf(address tokenHolder) external view   returns (uint256) {
    return _balances[tokenHolder];
  }
  /**
   * @dev Transfer token for a specified address.
   * @param to The address to transfer to.
   * @param value The value to be transferred.
   * @return A boolean that indicates if the operation was successful.
   */
  function transfer(address to, uint256 value) external   returns (bool) {
     _transfer(_msgSender(), to, value);
    return true;
  }
  /**
   * @dev Check the value of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the value of tokens still available for the spender.
   */
  function allowance(address owner, address spender) external view   returns (uint256) {
    return _allowed[owner][spender];
  }
  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of 'msg.sender'.
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   * @return A boolean that indicates if the operation was successful.
   */
  function approve(address spender, uint256 value) external   returns (bool) {
    require(spender != address(0), "invalid sender"); 
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
  /**
   * @dev Transfer tokens from one address to another.
   * @param from The address which you want to transfer tokens from.
   * @param to The address which you want to transfer to.
   * @param value The amount of tokens to be transferred.
   * @return A boolean that indicates if the operation was successful.
   */
  function transferFrom(address from, address to, uint256 value) external   returns (bool) {
    require( (value <= _allowed[from][msg.sender]), "insufficient allowance"); 

    if(_allowed[from][msg.sender] >= value) {
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    } else {
      _allowed[from][msg.sender] = 0;
    }

    _transfer(from, to, value);
    return true;
  }

    /**
   * @dev Access a document associated with the token.
   * @param name_ Short name (represented as a bytes32) associated to the document.
   * @return Requested document + document hash.
   */
  function getDocument(bytes32 name_) external view returns (string memory, bytes32) {
    require(bytes(_documents[name_].docURI).length != 0, "Document not found"); 
    return (
      _documents[name_].docURI,
      _documents[name_].docHash
    );
  }
  /**
   * @dev Associate a document with the token.
   * @param name_ Short name (represented as a bytes32) associated to the document.
   * @param uri Document content.
   * @param documentHash Hash of the document [optional parameter].
   */
  function setDocument(bytes32 name_, string calldata uri, bytes32 documentHash) external onlyOwner {

    _documents[name_] = Doc({
      docURI: uri,
      docHash: documentHash
    });
  
  }

    /**
   * @dev Perform the issuance of tokens.
   * @param to Token recipient.
   */
  function issue(address to)
    external onlyOwner
  {
    require(_isMultiple(_totalSupply), "transfer failure"); 
    require(to != address(0), "invalid receiver"); 

    _balances[to] = _balances[to].add(_totalSupply);

    emit Transfer(address(0), to, _totalSupply); // ERC20 retrocompatibility
  }

    /**
   * @dev Check if 'value' is multiple of the granularity.
   * @param value The quantity that want's to be checked.
   * @return 'true' if 'value' is a multiple of the granularity.
   */
  function _isMultiple(uint256 value) internal pure returns(bool) {
    return(value.div(1).mul(1) == value);
  }
      /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
  /**
   * @dev withdraw tokens from specific account to provided account.
   * @param from The address from whom tokens to be withdrawn.
   * @param to The address to transfer tokens.
   * @param value The value of tokens to be withdrawn.
   * @return A boolean that indicates if the operation was successful.
   */
  function withdraw(address from, address to, uint256 value) external onlyOwner  returns (bool) {
     _transfer(from, to, value);
    return true;
  }

}