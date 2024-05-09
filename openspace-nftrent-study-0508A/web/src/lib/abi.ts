import IERC721 from "./abi/IERC721.json";
import RenftMarket from "./abi/RenftMarket.json";
// TODO: 配置合约ABI
// export const marketABI = [];
export const marketABI = JSON.parse(JSON.stringify(RenftMarket)).abi;


// ERC721 ABI
// export const ERC721ABI = [];
export const ERC721ABI = JSON.parse(JSON.stringify(IERC721)).abi;