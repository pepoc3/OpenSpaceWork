import OrderCard from "@/components/nft/OrderCard";
import { useFethcMarketListing } from "@/lib/fetch";
import { RentoutOrderEntry } from "@/types";

export default function MarketListing() {
  const listResponse = useFethcMarketListing();
  return (
    <>
      <h1 className="text-center text-3xl p-4">Market Listing</h1>
      <div className="grid md:grid-cols-4 sm:grid-cols-3 w-full gap-2.5">
        {listResponse.data &&
          listResponse.data.map((order: RentoutOrderEntry) => (
            <OrderCard order={order} key={order.id} />
          ))}
      </div>
    </>
  );
}
