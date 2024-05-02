import {
  Approval as ApprovalEvent,
  ApprovalForAll as ApprovalForAllEvent,
  Transfer as TransferEvent,
} from "../generated/templates/S2NFT/S2NFT"
import { Approval, ApprovalForAll, Transfer, TokenInfo } from "../generated/schema"
import { S2NFT } from "../generated/S2NFT/S2NFT"


export function handleApproval(event: ApprovalEvent): void {
  let entity = new Approval(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.owner = event.params.owner
  entity.approved = event.params.approved
  entity.tokenId = event.params.tokenId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleApprovalForAll(event: ApprovalForAllEvent): void {
  let entity = new ApprovalForAll(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.owner = event.params.owner
  entity.operator = event.params.operator
  entity.approved = event.params.approved

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleTransfer(event: TransferEvent): void {
  let entity = new Transfer(
    event.transaction.hash.concatI32(event.logIndex.toI32()),
  )
  entity.from = event.params.from
  entity.to = event.params.to
  entity.tokenId = event.params.tokenId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()

  tokenInfo(event)
}

export function tokenInfo(event: TransferEvent): void {
  let contract = S2NFT.bind(event.address)
  let id = event.address.toHexString() + '-' + event.params.tokenId.toHexString()  

  // Load existing token info or create a new one
  let tokenInfo = TokenInfo.load(id)
  if(!tokenInfo){
    tokenInfo = new TokenInfo(id)
    // Prepare new data for token info
    tokenInfo.ca = event.address
    tokenInfo.tokenId = event.params.tokenId
    tokenInfo.tokenURL = contract.tokenURI(event.params.tokenId)
    tokenInfo.name = contract.name()
  }
  // Update token info data
  tokenInfo.owner = event.params.to
  tokenInfo.blockNumber = event.block.number
  tokenInfo.blockTimestamp = event.block.timestamp
  tokenInfo.transactionHash = event.transaction.hash

  //Save the token info
  tokenInfo.save()
}