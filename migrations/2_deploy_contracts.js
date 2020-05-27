let System = artifacts.require('./System.sol');

module.exports = async function (deployer) {
  
  deployer.deploy(System).then(_tokenization =>{
  
     console.log(_tokenization.address)
   })
  
  
};
