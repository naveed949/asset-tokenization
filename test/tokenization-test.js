const Tokenization = artifacts.require('AssetTokenization')
const System = artifacts.require('System')
const truffleAssert = require('truffle-assertions')




contract('Tokenization', accounts => {
  let tokenization;
  let tokenization2;
  let system;
  const issuer = accounts[0]
  const user1 = accounts[1]
  const user2 = accounts[2]
  const user3 = accounts[3]
  const user4 = accounts[4]
  const owner = accounts[5]

  let name = "Asset";
  let symbol = "AST";
  let supply = 100;
  it('Deploy System contract', async () =>{
    system   = await System.new({from: owner});
    
  })
  it('Deploy asset-tokenization contract from System contract', async () =>{
    let tx = await system.tokenize(name,symbol,supply,{from: owner});
    truffleAssert.eventEmitted(tx, 'Tokenization', (ev) => {
      tokenization2 = ev.contractAddress;
      return ev.name == name && ev.symbol == symbol && ev.supply == supply;
    })
  })
  it('Issue tokens from System contract', async () =>{
    let tx = await system.issueTokens(symbol,issuer,{from: owner});
    truffleAssert.eventEmitted(tx, 'Issued', (ev) => {
      return ev.symbol == symbol && ev.owner == issuer && ev.contractAddress == tokenization2;
    })
  })
  it('Fetch Token\'s address from System contract', async () =>{
    let tx = await system.getTokenContract(symbol);
    assert.equal(tx.toString(),tokenization2+"");
  })
  it('Set Asset\'s Document from System contract', async () => {
    let docName = "my_document"
    let docUri = "http://example.com/pdf"
    let docHash = "hashofdoc"
    
    let tx = await system.setDocument(web3.utils.fromUtf8(docName),docUri,web3.utils.fromUtf8(docHash),symbol,{from: owner});
    truffleAssert.eventEmitted(tx, 'Document', (ev) => {
      return ev.uri === docUri;
  });
  })
  it('Should Asset\'s Tokenization contract configured', async () => {
    tokenization = await Tokenization.at(tokenization2);
    let _name = await tokenization.name({from: issuer});
    let _sybmol = await tokenization.symbol({from: issuer});
    let _supply = await tokenization.totalSupply({from: issuer});
    let _balance = await tokenization.balanceOf(issuer);
    assert.equal(_name.toString(),name)
    assert.equal(_sybmol.toString(),symbol)
    assert.equal(_supply.toNumber(),supply)
    assert.equal(_balance.toNumber(),supply)
  })

it('Fetch Document from Asset-tokenization contract', async () => {
  let docName  = "my_document"
  let docUri   = "http://example.com/pdf"
  let docHash = "hashofdoc"
  let tx       = await tokenization.getDocument(web3.utils.fromUtf8(docName));
  assert.equal(tx[0],docUri)
  assert.equal(web3.utils.toUtf8(tx[1]),docHash)
})
it('transfer tokens to user1', async () =>{
  let tx = await tokenization.transfer(user1,2,{from: issuer})
  truffleAssert.eventEmitted(tx, 'Transfer', (ev) => {
    return ev.from === issuer && ev.to == user1 && ev.value == 2 ;
});
})
it('user1 should not spend more than his balance', async () =>{
  truffleAssert.reverts( 
                        tokenization
                        .transfer(user2,3,{from: user1})
                        ,"transfer amount exceeds balance");
  
})
it('user1 should approve user2 as spender', async () =>{
  
  let tx = await tokenization.approve(user2,1,{from: user1});
  truffleAssert.eventEmitted(tx, 'Approval', (ev) => {
    return ev.owner === user1 && ev.spender == user2 && ev.value == 1 ;
});

})
it('Fetch allowance of user2 approved by user1', async () => {
  
  let tx       = await tokenization.allowance(user1,user2);
  assert.equal(tx.toNumber(),1)
})
it('user2 should spend on behalf of user1', async () =>{
  
  let tx = await tokenization.transferFrom(user1,user3,1,{from: user2});
  truffleAssert.eventEmitted(tx,"Transfer", (ev) =>{
    return ev.from == user1 && ev.to == user3 && ev.value == 1;
  })

})
it('user2 should not spend more then he\'s approved by user1', async () =>{
  
  truffleAssert.reverts(
                       tokenization
                       .transferFrom(user1,user3,2,{from: user2})
                       ,"insufficient allowance");
})

})