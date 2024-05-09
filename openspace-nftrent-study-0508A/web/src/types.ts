export interface NFTInfo {
  id: string;
  tokenId: string;
  ca: string;
  tokenURL: string;
  blockTimestamp: string;
  name: string;
  owner: string;
}

/*
 * @description: NFT出租信息
 */
export interface RentoutOrderMsg {
  maker: string; // 租户地址
  nft_ca: string; // NFT合约地址
  token_id: bigint; // NFT tokenId
  daily_rent: bigint; // 每日租金
  max_rental_duration: bigint; // 最大租赁时长
  min_collateral: bigint; // 最小抵押
  list_endtime: bigint; // 挂单结束时间
}

export interface RentoutOrderEntry extends RentoutOrderMsg {
  id: number;
  token_url: string;
  token_name: string;
  signature: string;
  created_at: string;
}
