import Image from "next/image";
import _ from "lodash";

import { LOADIG_IMG_URL, DEFAULT_NFT_IMG_URL, PROTOCOL_CONFIG } from "@/config";
import { useEffect, useState } from "react";
import { NFTInfo, RentoutOrderEntry, RentoutOrderMsg } from "@/types";
import { useFetchNFTMetadata } from "@/lib/fetch";
import { formatUnits } from "viem";
import { marketABI } from "../../lib/abi";
import { Address } from "viem";

import {
  type BaseError,
  useAccount,
  useWaitForTransactionReceipt,
  useWriteContract,
} from "wagmi";

export default function OrderCard(props: { order: RentoutOrderEntry }) {
  const { chainId } = useAccount();
  const { order } = props;
  const nft: NFTInfo = {
    id: `${order?.nft_ca}#${order?.token_id?.toString()}`,
    tokenURL: order.token_url,
    name: order.token_name,
    tokenId: order.token_id?.toString(),
    ca: order.nft_ca,
    owner: "",
    blockTimestamp: "",
  };
  const metaRes = useFetchNFTMetadata(nft);
  const [image, setImage] = useState(LOADIG_IMG_URL);
  const [hover, setHover] = useState(false);

  useEffect(() => {
    setImage(
      metaRes.isLoading
        ? LOADIG_IMG_URL
        : metaRes.data?.image || DEFAULT_NFT_IMG_URL
    );
  }, [metaRes]);

  const { data: hash, isPending, error, writeContract } = useWriteContract();
  const { isLoading: isConfirming, isSuccess: isConfirmed } =
    useWaitForTransactionReceipt({ hash });

  const handleOpen = (e: React.FormEvent<HTMLButtonElement>) => {
    e.preventDefault();

    //TODO: 写合约，执行Borrow 交易
    // const mkt = useMarketContract();
    // return writeContract({
    //   address: nft?.ca as Address,
    //   abi: marketABI,
    //   functionName: "borrow",
    //   args: [mkt?.address, nft?.tokenId],
    // })
  };

  return (
    order &&
    chainId && (
      <div
        key={order.id}
        className="card card-compact bg-base-100 shadow-xl hover:border"
        onMouseOver={() => setHover(true)}
        onMouseLeave={() => setHover(false)}
      >
        <figure>
          <Image
            src={image}
            placeholder="blur"
            blurDataURL={LOADIG_IMG_URL}
            width={300}
            height={200}
            unoptimized={true}
            alt=""
            onError={() => {
              setImage(DEFAULT_NFT_IMG_URL);
            }}
          ></Image>
        </figure>
        <div className="card-body">
          <h2 className="card-title text-sm">{nft.name}</h2>
          <p className="text-small">
            {"Ξ" + formatUnits(order.daily_rent, 18)} {" X "}
            {Number(order.max_rental_duration) / (60 * 60 * 24)} {"Days"}
          </p>
          {hover && (
            <>
              <div className="card-actions ">
                <label
                  htmlFor={`orderModal_${order.id}`}
                  className="btn btn-primary min-w-full"
                >
                  Rent
                </label>
              </div>

              <div>
                <input
                  type="checkbox"
                  id={`orderModal_${order.id}`}
                  className="modal-toggle"
                />
                <dialog id={`orderModal_${order.id}`} className="modal">
                  <div className="modal-box">
                    <h3 className="font-bold text-lg">{nft.name}</h3>
                    <div className="card bg-base-100 shadow-xl">
                      <figure>
                        <Image
                          src={image}
                          width={500}
                          height={500}
                          unoptimized={true}
                          alt=""
                        ></Image>
                      </figure>
                      <div className="card-body">
                        <div>
                          <ul>
                            <li>
                              <span className="font-bold">NFT地址:</span>{" "}
                              {nft.ca}
                            </li>
                            <li>
                              <span className="font-bold">NFT编号:</span>{" "}
                              {nft.tokenId}
                            </li>
                            <li>
                              <span className="font-bold">出租方:</span>{" "}
                              {order.maker}
                            </li>
                            <li>
                              <span className="font-bold">抵押物:</span>{" "}
                              {"Ξ" + formatUnits(order.min_collateral, 18)}
                            </li>
                            <li>
                              <span className="font-bold">日租金:</span>{" "}
                              {"Ξ" + formatUnits(order.daily_rent, 18)}
                            </li>
                            <li>
                              <span className="font-bold">最长租期:</span>{" "}
                              {Number(order.max_rental_duration) /
                                (60 * 60 * 24)}
                              {"天"}
                            </li>
                          </ul>
                        </div>
                        <div className="card-actions justify-end">
                          {hash && <div>交易ID: {hash}</div>}
                          {isConfirming && <div>等待交易确认...</div>}
                          {isConfirmed && <div>交易已确认</div>}
                          {error && (
                            <div className="text-error">
                              Error:{" "}
                              {(error as BaseError).shortMessage ||
                                error.message}
                            </div>
                          )}
                          <button
                            disabled={isPending}
                            className="btn btn-primary w-full"
                            onClick={handleOpen}
                          >
                            {isPending ? "确认交易..." : "确认租赁"}
                          </button>
                          <label
                            htmlFor={`orderModal_${order.id}`}
                            className="btn w-full"
                          >
                            取消
                          </label>
                        </div>
                      </div>
                    </div>
                  </div>
                </dialog>
              </div>
            </>
          )}
        </div>
      </div>
    )
  );
}
