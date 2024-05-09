import { createPublicClient, webSocket, http, parseAbiItem } from "viem";
import { mainnet } from "viem/chains";
import {
  parseAbi,
  encodePacked,
  decodeAbiParameters,
  encodeAbiParameters,
} from "viem";

// import SEPOLIA_RPC = process.env.SEPOLIA_RPC;
const abi = parseAbi([
  "function name() public view returns (string memory)",
  "function balanceOf(address owner) view returns (uint256)",
  "function transfer(address to, uint256 value) public returns (bool)",
  "event Transfer(address indexed from, address indexed to, uint256 amount)",
]);

// 编码ABI
// 注意使用 encodePacked 是一个紧凑的数据编码方式
const encodeData = encodeAbiParameters(abi[2].inputs, [
  "0xFb19ffd1Ff9316b7f5Bba076eF4b78E4bBeDf4E1",
  BigInt(753000000),
]);
// console.log("encodeData:", encodeData);

const decodeDatas = decodeAbiParameters(abi[2].inputs, encodeData);
// console.log("decodeDatas:", decodeDatas);

// const filter = await publicClient.createEventFilter()

// 1. 知道自己的合约的ABI
// 2. 然后才能根据ABI去解析数据

// 需要定义一个 RPC 作为查询原
const client = createPublicClient({
  chain: mainnet,
  transport: http(
    "https://rpc.particle.network/evm-chain?chainId=1&projectUuid=164aa544-c065-4506-8daa-d872fe3cefbe&projectKey=cdUZE2fwysCUDnTmX3QADZaRa3iB8DLhL3o3EhCe"
  ),
});

async function fethTransferLogs() {
  let startBlock = await client.getBlockNumber();
  startBlock = startBlock - BigInt(40);

  for (let i = 0; i < 100000; i++) {
    const currentBlock = await client.getBlockNumber();
    // 我们不采集最新的3个区块的数据，如果太了，我们等一会，等数据稳定
    // POS
    if (startBlock > currentBlock - BigInt(3)) {
      console.log("等一会，等数据稳定");
      await new Promise((resolve) => setTimeout(resolve, 1000));
      continue;
    }
    const endBlock = startBlock + BigInt(10);
    console.log("采集区块:", startBlock, endBlock);
    const filter = await client.createEventFilter({
      address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
      event: parseAbiItem(
        "event Transfer(address indexed from, address indexed to, uint256 value)"
      ),
      fromBlock: BigInt(startBlock),
      toBlock: endBlock,
    });

    // check 高度是否超过了当前区块高度，如果是，则等会采集
    startBlock = endBlock + BigInt(1);

    const logs = await client.getFilterLogs({ filter });
    onTransfer(logs);
  }
}

function onTransfer(logs: any) {
  logs.forEach((log: any) => {
    console.log(
      `从 ${log.args.from} 转账给 ${log.args.to} ${
        log.args.value! / BigInt(1e6)
      }USDT,https://etherscan.io/tx/${log.transactionHash}`
    );
  });
}

async function watchTransferEvents() {
  const unwatch = client.watchEvent({
    address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
    event: parseAbiItem(
      "event Transfer(address indexed from, address indexed to, uint256 value)"
    ),
    onLogs: onTransfer,
  });

  setTimeout(unwatch, 20 * 1000);
}

async function watchNewBlock() {
  client.watchBlocks({
    onBlock: (block) => {
      console.log("block:", block.hash, block.number);
    },
  });
  client.watchBlockNumber({
    onBlockNumber: (blockNumber) => {
      console.log("blockNumber:", blockNumber);
    },
  });
}

watchNewBlock().catch((err) => console.log(err));
