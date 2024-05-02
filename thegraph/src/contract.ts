import {
  NFTCreated as NFTCreatedEvent,
  NFTRegesitered as NFTRegesiteredEvent,
  OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/Contract/Contract"
import {
  NFTCreated,
  NFTRegesitered,
  OwnershipTransferred
} from "../generated/schema"

import { S2NFT } from '../generated/templates'

export function handleNFTCreated(event: NFTCreatedEvent): void {
  let entity = new NFTCreated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash
  S2NFT.create(event.params.nftCA)
  entity.save()
}

export function handleNFTRegesitered(event: NFTRegesiteredEvent): void {
  let entity = new NFTRegesitered(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash
  S2NFT.create(event.params.nftCA)
  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
