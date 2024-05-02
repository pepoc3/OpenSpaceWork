import { newMockEvent } from "matchstick-as"
import { ethereum, Address } from "@graphprotocol/graph-ts"
import {
  NFTCreated,
  NFTRegesitered,
  OwnershipTransferred
} from "../generated/Contract/Contract"

export function createNFTCreatedEvent(nftCA: Address): NFTCreated {
  let nftCreatedEvent = changetype<NFTCreated>(newMockEvent())

  nftCreatedEvent.parameters = new Array()

  nftCreatedEvent.parameters.push(
    new ethereum.EventParam("nftCA", ethereum.Value.fromAddress(nftCA))
  )

  return nftCreatedEvent
}

export function createNFTRegesiteredEvent(nftCA: Address): NFTRegesitered {
  let nftRegesiteredEvent = changetype<NFTRegesitered>(newMockEvent())

  nftRegesiteredEvent.parameters = new Array()

  nftRegesiteredEvent.parameters.push(
    new ethereum.EventParam("nftCA", ethereum.Value.fromAddress(nftCA))
  )

  return nftRegesiteredEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent = changetype<OwnershipTransferred>(
    newMockEvent()
  )

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}
