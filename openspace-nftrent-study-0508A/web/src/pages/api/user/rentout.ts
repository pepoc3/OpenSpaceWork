import type { NextApiRequest, NextApiResponse } from "next";
import { verifyTypedData } from "@wagmi/core";
import { wagmiConfig, PROTOCOL_CONFIG, eip721Types } from "@/config";
import { NFTInfo, RentoutOrderMsg } from "@/types";
import { saveOrder } from "@/pages/api/db";
import { chain } from "lodash";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method === "POST") {
    try {
      const { chainId, order, signature, nft } = req.body;
      if (!order || !signature) {
        return res.status(200).json({ error: "Invalid request" });
      } else {
        const orderInfo = order as RentoutOrderMsg;
        const ok = await verifyingOrder(chainId, orderInfo, signature);
        if (ok) {
          // 验证签名通过后，将订单存储到数据库
          await saveOrder(chainId, orderInfo, nft as NFTInfo, signature);
          return res.status(200).json({ success: true });
        } else {
          // 如果失败，则提示签名错误
          return res.status(200).json({ error: "Invalid signature" });
        }
      }
    } catch (error: any) {
      return res.status(200).json({ error: error.message || error });
    }
  } else {
    // Handle any other HTTP method
    return res.status(404).end();
  }
}

// 校验出租订单签名 https://wagmi.sh/core/api/actions/verifyTypedData#message
function verifyingOrder(
  chainId: any,
  order: any,
  signature: any
): Promise<boolean> {
  // TODO: 验证订单签名
  // return false as any;
  return verifyTypedData(wagmiConfig, {
    chainId: chainId,
    domain: PROTOCOL_CONFIG[chainId].domain,
    types: eip721Types,
    message: order,
    primaryType: "RentoutOrder",
    address: order.maker,
    signature: signature,
  });
}
