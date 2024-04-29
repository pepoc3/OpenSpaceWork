import { createPublicClient, http, webSocket,Filter } from 'viem';
import { mainnet } from 'viem/chains';

import {
    parseAbi,
    parseAbiItem,
    encodePacked,
    decodeAbiParameters,
    encodeAbiParameters,
} from 'viem';

const client = createPublicClient ({
    chain: mainnet,
    transport: http("https://rpc.particle.network/evm-chain?chainId=1&projectUuid=6640e582-6ee3-4910-891b-a5564834a219&projectKey=cJIoM9yJEcCMHLosB7fGaemT0Ts11qQDO4uIeeoX"),
});

async function main() {
    const latestBlock = await client.getBlockNumber();
    let startBlock = latestBlock-BigInt(100);
    const filter = await client.createEventFilter({
        address:"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
        event: parseAbiItem("event Transfer(address indexed from, address indexed to, uint256 value)"),
        fromBlock: BigInt(startBlock),
        toBlock: BigInt(latestBlock),
    });
    
    const logs = await client.getFilterLogs({filter}) ;

    
    logs.forEach((log)=> {
    console.log(
        `从 ${log.args.from} 转账给 ${log.args.to} ${log.args.value!/ BigInt(1e6)}USDC,交易ID:${log.transactionHash}`
    );  
});
}

main().catch((err)=> console.log(err));