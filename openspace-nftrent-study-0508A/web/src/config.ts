import { defaultWagmiConfig } from "@web3modal/wagmi/react/config";

import { cookieStorage, createStorage } from "wagmi";
import { localhost, mainnet, sepolia } from "wagmi/chains";

(BigInt.prototype as any).toJSON = function () {
  return this.toString();
};

// Get projectId at https://cloud.walletconnect.com
export const projectId = process.env.NEXT_PUBLIC_PROJECT_ID;

if (!projectId) throw new Error("Project ID is not defined");

// 来自于已经部署的 thegraph：
export const RENFT_GRAPHQL_URL = process.env.NEXT_PUBLIC_RENFT_GRAPHQL_URL;

if (!RENFT_GRAPHQL_URL) throw new Error("RENFT_GRAPHQL_URL is not defined");

export const LOADIG_IMG_URL = "/images/loading.svg";
export const DEFAULT_NFT_IMG_URL = "/images/empty_nft.png";

const metadata = {
  name: "Web3Modal",
  description: "Web3Modal Example",
  url: "https://web3modal.com", // origin must match your domain & subdomain
  icons: ["https://avatars.githubusercontent.com/u/37784886"],
};

// Create wagmiConfig
const chains = [mainnet, sepolia] as const;
export const config = defaultWagmiConfig({
  chains,
  projectId,
  metadata,
  ssr: true,
  storage: createStorage({
    storage: cookieStorage,
  }),
  // ...wagmiOptions, // Optional - Override createConfig parameters
});

import { http, createConfig } from "@wagmi/core";
export const wagmiConfig = createConfig({
  chains: [mainnet, sepolia],
  transports: {
    [mainnet.id]: http("https://ethereum-rpc.publicnode.com"),
    [sepolia.id]: http("https://ethereum-sepolia-rpc.publicnode.com"),
  },
});

import { type TypedData } from "viem";

// 协议配置
export const PROTOCOL_CONFIG = {
  [Number(sepolia.id)]: {
    domain: {
      // TODO: 配置EIP-712签名域名信息
      name: 'RenftMarket',
      version: "1",
      chainid: 11155111,
      verifyingContract: '0xcAc342Bd1d673bd47e8079AD1e4a91Cd9021D0Bb',
    },
    rentoutMarket: "0xcAc342Bd1d673bd47e8079AD1e4a91Cd9021D0Bb", // TODO: 配置出租市场合约地址
  },
} as const;

// EIP-721 签名类型
export const eip721Types = {
  // 出租NFT的挂单信息结构
  RentoutOrder: [
    // TODO: 定义出租订单结构数据
    { name: 'maker', type: 'address' },
    { name: 'nft_ca', type: 'address' },
    { name: 'token_id', type: 'uint256' },
    { name: 'daily_rent', type: 'uint256' },
    { name: 'max_rental_duration', type: 'uint256' },
    { name: 'min_collateral', type: 'uint256' },
    { name: 'list_endtime', type: 'uint256' },
  ],
} as const as TypedData;
