  
const HDWalletProvider = require('truffle-hdwallet-provider')
const {
  readFileSync
} = require('fs')
const path = require('path')

module.exports = {
  networks: {
    rinkeby: {
      provider: function () {
        const mnemonic = readFileSync(path.join(__dirname, 'rinkeby_mnemonic'), 'utf-8')
     
        return new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/a9f521235df94d829754f89f68101a76`, 0, 1)
      },
      network_id: 4,
      gasPrice: 15000000001,
      skipDryRun: true
    },
    mainnet: {
      provider: function () {
        const mnemonic = readFileSync(path.join(__dirname, 'mainnet_mnemonic'), 'utf-8')
     
        return new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/a9f521235df94d829754f89f68101a76`, 0, 1)
      },
      network_id: 1,
      gasPrice: 15000000001,
      skipDryRun: true
    },
    local:{
      host:"localhost",
      port: 8545,
      network_id: "*"
    }
  },
  compilers: {
    solc: {
      version: '0.5.10',
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 0, // Default: 200
        },
      },
    },
  }
}