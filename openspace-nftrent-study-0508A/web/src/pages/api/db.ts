import { NFTInfo, RentoutOrderMsg } from "@/types";
import { sql } from "@vercel/postgres";
import { NextApiRequest, NextApiResponse } from "next";

const ADMIN_PWD = "openspace@s2";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // 初始化DB
    const { pwd } = req.query;
    if (pwd !== ADMIN_PWD) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    // 删除表
    await sql`drop table if exists rentout_orders;`;

    const result = await sql`CREATE TABLE IF NOT EXISTS rentout_orders (
        id SERIAL PRIMARY KEY,
        chain_id INTEGER NOT NULL,
        taker TEXT,
        nft_ca TEXT,
        token_url TEXT,
        token_name TEXT,
        token_id TEXT, 
        max_rental_duration INTEGER,
        daily_rent decimal(20,0),
        min_collateral decimal(20,0),
        list_endtime INTEGER, 
        signature TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );`;
    return res.status(200).json({ result });
  } catch (error) {
    return res.status(500).json({ error: error });
  }
}

// 存储订单信息
export async function saveOrder(
  chainId: number,
  order: RentoutOrderMsg,
  nft: NFTInfo,
  signature: string
) {
  // TODO: 验证提交的订单信息是否合法
  // 先删除已存在的记录
  await sql`delete from rentout_orders where chain_id = ${chainId} and nft_ca = ${
    order.nft_ca
  } and token_id = ${order.token_id.toString()}`;

  // 插入新记录
  return sql`insert into rentout_orders (chain_id, maker, nft_ca, token_id, max_rental_duration, daily_rent, min_collateral, list_endtime,token_url,token_name,signature) 
   values (${chainId}, ${order.maker}, ${
    order.nft_ca
  }, ${order.token_id.toString()}, 
    ${order.max_rental_duration.toString()}, 
    ${order.daily_rent.toString()}, 
    ${order.min_collateral.toString()},
    ${order.list_endtime.toString()},${nft.tokenURL},${nft.name}, ${signature})
   `;
}
