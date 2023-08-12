# OmniPay

<p align="center">
  <a href="https://omnipay.surge.sh/" target="_blank">
    <img src="./frontend/public/omnipay-circle.png" width="225" alt="OmniPay Logo">
  </a>
  <div align="center">Deposit once, pay anywhere</div>
  <div align="center">🔴 🔵 Created for <a href="https://ethglobal.com/events/superhack" target="_blank">ETHGlobal Superhack</a> 🪩 ⚪️</div>
</p>

## 📖 Inspiration

OmniPay is built to solve the problem of having to deposit funds into multiple chains to pay for different services. I wanted to create a solution that would allow users to deposit funds once and pay on any blockchain they want.

Current solutions like [Connext](https://connext.network/) and [Hop](https://hop.exchange/) are great, but they require users to deposit funds into a specific chain. This means that if a user wants to pay for a service on a different chain, they would have to deposit funds into that chain as well. This is not ideal as it requires depositing funds into multiple chains, which can be expensive and time consuming.

## 📝 Description

OmniPay is built on top of [LayerZero](https://layerzero.network/), a cross-chain communication protocol that allows users to send messages between different blockchains. OmniPay stores user fund data in a single smart contract on Optimism. When a user wants to deposit or withdraw, they communicate with the smart contract on Optimism via LayerZero. The smart contract then sends a message to the smart contract on the source chain to deposit or withdraw funds. This allows users to deposit funds on any chain they want, and withdraw funds from any chain they want.

## 📱 Demo

To check out OmniPay, visit [omnipay.surge.sh](https://omnipay.surge.sh/). You can test transferring balances between four different chains: [Optimism](https://optimism.io/), [Base](https://base.org), [Zora](https://zora.co/), and [Mode](https://mode.network/).

## 🛠 Built With

- [LayerZero](https://layerzero.network/)
- [Foundry](https://getfoundry.sh)
- [React](https://reactjs.org/)
- [TypeScript](https://www.typescriptlang.org/)

## 🏃 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/en/)
- [Foundry](https://getfoundry.sh)

### Installation

1. Clone the repo

   ```sh
   git clone https://github.com/altugbakan/omnipay.git
   ```

2. Copy the `.env.example` files in frontend, contracts, and router folders, and rename them to `.env`. Fill in the required environment variables.

   ```sh
   cp frontend/.env.example frontend/.env
   cp contracts/.env.example contracts/.env
   cp router/.env.example router/.env
   ```

3. Run the deployment script once. This will generate the ABI and the contract addresses for the contracts. _Note: To actually deploy the contracts, use the `--broadcast` flag. You will need at least 0.2 ETH on each chain._

   ```sh
   cd contracts && forge script script/OmniPay.s.sol:Deploy && cd ..
   ```

4. Run the router bot. This will start the router bot and listen for messages on the chains that are not supported by LayerZero.

   ```sh
   cd router && npm start
   ```

5. On a new terminal, run the frontend. This will start the frontend.

   ```sh
   cd frontend && npm run dev
   ```

## 📄 License

Distributed under the MIT License. See [LICENSE.md](./LICENSE.md) for more information.
