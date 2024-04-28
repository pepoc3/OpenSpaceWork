export interface NFTInfo {
  id: string;
  address: string;
  isSemiFungible: boolean;
  tokenId: string;
  tokenBalance: string;
  tokenURI: string;
  name: string;
  symbol: string;
  image: string;
  data: {
    name: string;
    image: string;
    description: string;
    animation_url: string;
  };
  isScam: boolean;
  animationUrl: string;
}
