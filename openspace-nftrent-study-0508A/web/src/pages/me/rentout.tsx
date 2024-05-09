import _ from "lodash";
import { useState, FormEvent, useRef } from "react";
import classNames from "classnames";
import { toast } from "react-toastify";

import NFTCard from "@/components/nft/NFTCard";
import Link from "next/link";

import SelectNFT from "@/components/nft/SelectNFT";
import { NFTInfo, RentoutOrderMsg } from "@/types";
import { useUserNFTs, useWriteApproveTx } from "@/lib/fetch";
import { useAccount } from "wagmi";

import { signTypedData, getAccount } from "@wagmi/core";
import { config, eip721Types, PROTOCOL_CONFIG, wagmiConfig } from "@/config";
import { parseUnits } from "viem";

export default function Rentout() {
  const nftResp = useUserNFTs();
  const { address: userWallet, chainId } = useAccount();

  const [selectedNft, setSelectedNft] = useState<NFTInfo | null>(null);
  const [step, setStep] = useState(1);

  const [rentalDuration, setRentalDuration] = useState(7);
  const [listLifetime, setListLifetime] = useState(7);

  const handleSelectNft = (nft: NFTInfo) => {
    console.log("when select");
    if (selectedNft?.id === nft.id) {
      setSelectedNft(null);
    } else {
      setSelectedNft(nft);
    }
  };

  const handleConfirm = (nft: NFTInfo) => {
    console.log("when confirm");
    setSelectedNft(nft);
    setStep(2);
  };

  // submit loading
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const maxRentalDurationRef = useRef<HTMLInputElement>(null);
  const dailyRentRef = useRef<HTMLInputElement>(null);
  const collateralRef = useRef<HTMLInputElement>(null);
  const listLifetimeRef = useRef<HTMLInputElement>(null);

  const approveHelp = useWriteApproveTx(selectedNft);

  const handleApprove = async () => {
    await approveHelp.sendTx();
  };

  // submit listing order
  const handleSubmitListing = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!selectedNft) return;

    setIsLoading(true);

    try {
      if (!approveHelp.isApproved) {
        return;
      }

      // 获取 NFT 基本信息
      const oneday = 24 * 60 * 60;
      const order = {
        maker: userWallet!,
        nft_ca: selectedNft.ca,
        token_id: BigInt(selectedNft.tokenId),
        daily_rent: parseUnits(dailyRentRef.current!.value, 18),
        max_rental_duration: BigInt(
          Number(maxRentalDurationRef.current!.value) * oneday
        ),
        min_collateral: parseUnits(collateralRef.current!.value, 18),
        list_endtime: BigInt(
          Math.ceil(Date.now() / 1000) +
            Number(listLifetimeRef.current!.value) * oneday
        ),
      } as RentoutOrderMsg;

      console.log("info:", chainId, PROTOCOL_CONFIG[chainId!].domain);

      // TODO 请求钱包签名，获得签名信息
      // const signature = "0x0000...0000";
      const signature = await signTypedData(config, {
        connector,
        domain: PROTOCOL_CONFIG[chainId!].domain,
        types: eip721Types,
        primaryType: "RentoutOrder",
        message: order,
      })

      console.log("signature", signature);

      const res = await fetch("/api/user/rentout", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          order,
          signature,
          chainId,
          nft: selectedNft,
        }),
      });
      if (res.ok) {
        const data = await res.json();
        if (data.error) {
          throw new Error(data.error);
        }
      }

      setStep(3);
    } catch (error: any) {
      toast.error(error.message, {
        position: "bottom-center",
        className: "min-w-full",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="grid gap-y-6">
      <h2 className="min-w-full text-center font-bold text-pink-600">
        Rent out NFT , Earn ETH
      </h2>

      <ul className="steps min-w-full cursor-pointer">
        <li className="step step-primary" onClick={() => setStep(1)}>
          Select NFT
        </li>
        <li
          className={classNames("step", step >= 2 && "step-primary")}
          onClick={() => selectedNft && setStep(2)}
        >
          Sign List Order
        </li>
        <li className={classNames("step", step >= 3 && "step-primary")}>
          Earn ETH
        </li>
      </ul>

      {nftResp.isLoading && (
        <>
          <div className="flex flex-col gap-4 w-52">
            <div className="skeleton h-32 w-full"></div>
            <div className="skeleton h-4 w-28"></div>
            <div className="skeleton h-4 w-full"></div>
            <div className="skeleton h-4 w-full"></div>
          </div>
        </>
      )}
      {step === 1 && nftResp.data && (
        <div className="grid md:grid-cols-4 sm:grid-cols-3 w-full gap-2.5">
          {nftResp.data.map((nft: any) => (
            <SelectNFT
              key={nft.id}
              nft={nft}
              selected={nft.id === selectedNft?.id}
              onClick={handleSelectNft}
              onConfirm={handleConfirm}
            ></SelectNFT>
          ))}
        </div>
      )}
      {step === 2 && selectedNft && (
        <>
          <div className="flex w-full justify-center gap-12">
            <NFTCard nft={selectedNft} />
            <div className="grid">
              <form onSubmit={(e) => handleSubmitListing(e)}>
                <label className="form-control  w-full max-w-xs">
                  <div className="label">
                    <span className="label-text">Max Rental Duration</span>
                    <span className="label-text-alt"></span>
                  </div>
                  <label className="range">
                    <input
                      required
                      type="range"
                      min="0.5"
                      max="365"
                      step="0.5"
                      value={rentalDuration}
                      ref={maxRentalDurationRef}
                      onChange={(e) =>
                        setRentalDuration(Number(e.target.value))
                      }
                      className="range range-xs range-primary"
                    />
                  </label>
                  <div className="label">
                    <span className="label-text"></span>
                    <label className="label-text-alt">
                      {rentalDuration} days
                    </label>
                  </div>
                </label>
                <label className="form-control  w-full max-w-xs">
                  <div className="label">
                    <span className="label-text">Daily Rent</span>
                    <span className="label-text-alt"></span>
                  </div>
                  <label className="input input-bordered flex items-center gap-2">
                    <input
                      type="number"
                      ref={dailyRentRef}
                      className="grow"
                      name="dailyRent"
                      step={0.0000001}
                      required
                    />
                    <span className="">ETH</span>
                  </label>
                  <div className="label">
                    <span className="label-text"></span>
                    <span className="label-text-alt text-base-500">
                      Est. Max earn:0.2 ETH
                    </span>
                  </div>
                </label>
                <label className="form-control  w-full max-w-xs">
                  <div className="label">
                    <span className="label-text">Min Collateral</span>
                    <span className="label-text-alt"></span>
                  </div>
                  <label className="input input-bordered flex items-center gap-2">
                    <input
                      type="number"
                      ref={collateralRef}
                      className="grow"
                      placeholder=""
                      step={0.00000001}
                      required
                    />
                    <span className="">ETH</span>
                  </label>
                  <div className="label">
                    <span className="label-text"></span>
                    <span className="label-text-alt text-base-500"></span>
                  </div>
                </label>
                <label className="form-control  w-full max-w-xs">
                  <div className="label">
                    <span className="label-text">Order List Expiry</span>
                    <span className="label-text-alt"></span>
                  </div>
                  <label className="range">
                    <input
                      required
                      type="range"
                      ref={listLifetimeRef}
                      min="0.5"
                      max="180"
                      step="0.5"
                      value={listLifetime}
                      onChange={(e) => setListLifetime(Number(e.target.value))}
                      className="range range-xs range-primary"
                    />
                  </label>
                  <div className="label">
                    <span className="label-text"></span>
                    <label className="label-text-alt">
                      {listLifetime} days
                    </label>
                  </div>
                </label>

                <label className="form-control  w-full max-w-xs">
                  {approveHelp.isApproved === false &&
                    !approveHelp.isConfirmed && (
                      <button
                        className="btn btn-primary"
                        onClick={handleApprove}
                        disabled={
                          approveHelp.isPending || approveHelp.isConfirming
                        }
                      >
                        {(approveHelp.isPending ||
                          approveHelp.isConfirming) && (
                          <span className="loading loading-ring loading-sm"></span>
                        )}
                        Approve first
                      </button>
                    )}
                  {(approveHelp.isApproved || approveHelp.isConfirmed) && (
                    <button
                      type="submit"
                      className="btn btn-primary"
                      disabled={isLoading}
                    >
                      {isLoading && (
                        <span className="loading loading-ring loading-sm"></span>
                      )}
                      List Now
                    </button>
                  )}
                </label>
              </form>
            </div>
          </div>
          <div className="flex  w-full justify-center gap-12">
            <p className="max-w-2xl text-base-200 hover:text-base-content">
              During the listing period, there is no need to lock your NFT. The
              transfer of NFT only occurs upon lending, allowing you to start
              earning rental income. At the end of the term, if the tenant fails
              to return the NFT, you have the option to liquidate (seize
              collateral) and terminate the lease.
            </p>
          </div>
        </>
      )}

      {step === 3 && selectedNft && (
        <>
          <div className="flex w-full justify-center gap-12  items-center">
            <NFTCard nft={selectedNft} />
            <div>
              <p className="text-primary mb-5">
                Congratulations, your NFT has been listed! After being leased,
                you can collect rent every day!
              </p>
              <div className="w-full justify-end flex">
                <Link href="/me" className="btn-link">
                  See My List
                </Link>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
