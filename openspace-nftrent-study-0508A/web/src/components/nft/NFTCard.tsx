import Image from "next/image";

import { LOADIG_IMG_URL, DEFAULT_NFT_IMG_URL } from "@/config";
import { useEffect, useState } from "react";
import { NFTInfo } from "@/types";
import { useFetchNFTMetadata } from "@/lib/fetch";

export default function NFTCard(props: { nft: NFTInfo }) {
  const metaRes = useFetchNFTMetadata(props.nft);
  const [image, setImage] = useState(LOADIG_IMG_URL);

  useEffect(() => {
    setImage(
      metaRes.isLoading
        ? LOADIG_IMG_URL
        : metaRes.data?.image || DEFAULT_NFT_IMG_URL
    );
  }, [metaRes]);

  return (
    <div className="card card-compact glass">
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
        <h2 className="card-title text-sm">{props.nft.name}</h2>
        <p className="text-sm max-w-60  text-base-content">
          {metaRes.data.description}
        </p>
      </div>
    </div>
  );
}
