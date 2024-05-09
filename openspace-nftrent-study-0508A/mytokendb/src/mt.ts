import {
  Approval as ApprovalEvent,
  Transfer as TransferEvent,
} from "../generated/MT/MT";
import { Approval, Transfer, TokenHolder } from "../generated/schema";

export function handleApproval(event: ApprovalEvent): void {
  let entity = new Approval(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.address; // 事件所发生的合约地址，就是我们跟踪的Token地址
  entity.owner = event.params.owner;
  entity.spender = event.params.spender;
  entity.value = event.params.value;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  //根据余额
}

export function handleTransfer(event: TransferEvent): void {
  let entity = new Transfer(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  );
  entity.token = event.address; // 事件所发生的合约地址，就是我们跟踪的Token地址
  entity.from = event.params.from;
  entity.to = event.params.to;
  entity.value = event.params.value;

  entity.blockNumber = event.block.number;
  entity.blockTimestamp = event.block.timestamp;
  entity.transactionHash = event.transaction.hash;

  entity.save();

  updateTokenBalance(entity);
}

// 更新Token持仓余额
function updateTokenBalance(action: Transfer): void {
  // 先更新 From  地址，再更新 To 地址的余额
  // id = `tokenaddress`
  let fromInfo = TokenHolder.load(action.token.concat(action.from));
  let toInfo = TokenHolder.load(action.token.concat(action.to));
  if (fromInfo) {
    //如果存在，则更新
    fromInfo.balance = fromInfo.balance.minus(action.value);
    fromInfo.update_blockNumber = action.blockNumber;
    fromInfo.update_blockTimestamp = action.blockTimestamp;
    fromInfo.update_transactionHash = action.transactionHash;
    fromInfo.save();
  }
  if (toInfo) {
    toInfo.balance = toInfo.balance.plus(action.value);
  } else {
    //不存在则创建
    toInfo = new TokenHolder(action.token.concat(action.to));
    toInfo.balance = action.value;
    toInfo.holder = action.to;
    toInfo.token = action.token;
  }
  toInfo.update_blockNumber = action.blockNumber;
  toInfo.update_blockTimestamp = action.blockTimestamp;
  toInfo.update_transactionHash = action.transactionHash;
  // 新增或者更新数据
  toInfo.save();
}
