import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address } from "@graphprotocol/graph-ts"
import { NFTCreated } from "../generated/schema"
import { NFTCreated as NFTCreatedEvent } from "../generated/Contract/Contract"
import { handleNFTCreated } from "../src/contract"
import { createNFTCreatedEvent } from "./contract-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let nftCA = Address.fromString("0x0000000000000000000000000000000000000001")
    let newNFTCreatedEvent = createNFTCreatedEvent(nftCA)
    handleNFTCreated(newNFTCreatedEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("NFTCreated created and stored", () => {
    assert.entityCount("NFTCreated", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "NFTCreated",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "nftCA",
      "0x0000000000000000000000000000000000000001"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
