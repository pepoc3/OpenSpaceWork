import useSWR from "swr";
import {
  useAccount,
  useReadContract,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";
import { gql, request } from "graphql-request";

import {
  RENFT_GRAPHQL_URL,
  DEFAULT_NFT_IMG_URL,
  config,
  PROTOCOL_CONFIG,
} from "@/config";
import { NFTInfo, RentoutOrderMsg } from "@/types";
import { sepolia } from "viem/chains";
import { readContract } from "viem/actions";
import { ERC721ABI, marketABI } from "./abi";
import { Address } from "viem";

interface GQL {
  query: string;
  variables: any;
}

interface queryResponse {
  tokenInfos: NFTInfo[];
}

interface NFTBalanceResponse {
  data: NFTInfo[] | undefined;
  error: any | undefined;
  isLoading: boolean;
}

const fetcher = (
  input: string | URL | globalThis.Request,
  init?: RequestInit
) => fetch(input, init).then((res) => res.json());

/**
 *
 * @returns
 */
export function useUserNFTs(): NFTBalanceResponse {
  const { address, isConnected } = useAccount();

  console.log("RENFT_GRAPHQL_URL:", RENFT_GRAPHQL_URL);
  const { data: result, error } = useSWR(
    isConnected
      ? {
          query: gql`
            query userNFTs($wallet: Bytes!) {
              tokenInfos(where: { owner: $wallet }) {
                id
                tokenId
                ca
                tokenURL
                blockTimestamp
                name
                owner
              }
            }
          `,
          variables: {
            wallet: address!.toLowerCase(),
          },
        }
      : null,
    (req: GQL) =>
      request<queryResponse>(RENFT_GRAPHQL_URL!, req.query, req.variables)
  );

  // 尚未登录时，返回空数据
  return {
    data: result?.tokenInfos,
    error,
    isLoading: !isConnected || error,
  };
}

export function useUserListing() {
  const { address, chainId, isConnected } = useAccount();
  const { data, error, isLoading } = useSWR(
    isConnected
      ? `/api/user/listing?chainId=${chainId!}&wallet=${address!}`
      : null,
    fetcher
  );
  if (error || !data) {
    return {
      data,
      error,
      isLoading,
    };
  } else if (data.code !== 0) {
    return {
      data: [],
      error: data.message,
      isLoading,
    };
  } else {
    return {
      data: data.data,
      error,
      isLoading,
    };
  }
}

// 获取NFT图片地址
// 1. 从tokenURL获取，如果是ipfs://开头，转换为https://cloudflare-ipfs.com/ipfs/
// 2. 如果tokenURL是json格式，获取image字段, 如果没有image字段，返回默认图片
export function useFetchNFTMetadata(nft: NFTInfo) {
  const {
    data: meta,
    error,
    isLoading,
  } = useSWR(nft?.tokenURL ? reserverURL(nft.tokenURL) : null, (url) =>
    fetch(url).then((res) => {
      if (res.ok) {
        const contentType = res.headers.get("content-type");
        // https://docs.opensea.io/docs/metadata-standards
        if (contentType && contentType.includes("application/json")) {
          return res.json().then((data) => {
            if (data.image) {
              data.image = reserverURL(data.image);
            } else if (data.image_data) {
              data.image = data.image_data;
            } else {
              data.image = DEFAULT_NFT_IMG_URL;
            }
            return data;
          });
        } else if (contentType && contentType.includes("image")) {
          return {
            image: url,
          };
        }
      }
      throw new Error("Failed to fetch image");
    })
  );
  return {
    data: meta,
    error,
    isLoading,
  };
}

// 转换ipfs://开头的url为https://cloudflare-ipfs.com/ipfs/
export function reserverURL(url: string) {
  if (url.startsWith("ipfs://")) {
    return url.replace("ipfs://", "https://cloudflare-ipfs.com/ipfs/");
  }
  return url;
}

// 获取市场上的NFT出租列表
export function useFethcMarketListing() {
  const { chainId } = useAccount();

  const { data, error, isLoading } = useSWR(
    `/api/listing?chainId=${chainId || sepolia.id}`,
    fetcher
  );
  console.log("useFethcMarketListing:", data, error, isLoading);
  return {
    data: data?.data,
    error: error ? error.message : data?.error,
    isLoading,
  };
}

export function useWriteApproveTx(nft: NFTInfo | null) {
  const { data: hash, isPending, error, writeContract } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({ hash });
  const mkt = useMarketContract();

  // 读合约：获取是否已经授权
  // https://wagmi.sh/react/api/hooks/useReadContract#type-inference
  // 或者检查是否有整个集合授权给MKT合约
  // var approveTo = undefined;

  // TODO 查询NFT是否已经授权给市场合约
  const { data: approveTo } = useReadContract ({
    abi: ERC721ABI,
    address: nft?.ca as Address,
    functionName: "getApproved",
    args: [nft?.tokenId],
  });
  
  return {
    hash,
    isPending,
    error,
    isConfirming,
    isConfirmed,
    isApproved: approveTo === mkt?.address,
    sendTx: () => {
      // TODO 写合约：调用NFT合约，将 NFT 授权给市场合约
      // https://wagmi.sh/react/guides/write-to-contract#_4-hook-up-the-usewritecontract-hook
      return writeContract({
        address: nft?.ca as Address,
        abi: ERC721ABI,
        functionName: "approve",
        args: [mkt?.address, nft?.tokenId],
      })
    },
  };
}

export function useMarketContract() {
  const { chainId } = useAccount();
  return chainId
    ? {
        address: PROTOCOL_CONFIG[chainId].rentoutMarket,
        abi: marketABI,
      }
    : undefined;
}
