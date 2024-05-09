import { NFTInfo } from "@/types";
import classNames from "classnames";

import Image from "next/image";
import { LOADIG_IMG_URL, DEFAULT_NFT_IMG_URL } from "@/config";
import { useEffect, useState } from "react";
import { useFetchNFTMetadata } from "@/lib/fetch";

export default function SelectNFT(props: {
  nft: NFTInfo;
  selected: Boolean;
  onClick: (nft: NFTInfo) => void;
  onConfirm: (nft: NFTInfo) => void;
}) {
  const { nft, selected, onClick, onConfirm } = props;

  const metaRes = useFetchNFTMetadata(props.nft);
  const [image, setImage] = useState(DEFAULT_NFT_IMG_URL);
  useEffect(() => {
    setImage(
      metaRes.isLoading
        ? LOADIG_IMG_URL
        : metaRes.data?.image || DEFAULT_NFT_IMG_URL
    );
  }, [metaRes]);
  return (
    <div
      className={classNames(
        "card card-compact bg-base-100 shadow-xl hover:border cursor-pointer",
        selected && "border image-full"
      )}
      onClick={() => onClick(nft)}
    >
      <figure>
        <Image
          placeholder="blur"
          blurDataURL={LOADIG_IMG_URL}
          src={image}
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
        <h2 className="card-title font-thin text-sm truncate w-full max-w-60">
          {nft.name}
        </h2>

        {selected && (
          <div className="card-actions justify-end">
            <button
              className="btn btn-primary btn-lg min-w-full"
              onClick={(e) => {
                e.stopPropagation();
                onConfirm(nft);
              }}
            >
              Confirm
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
