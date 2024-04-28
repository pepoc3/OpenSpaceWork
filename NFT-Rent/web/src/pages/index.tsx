import Image from "next/image";
import Link from "next/link";
const hotNFTs = [
  {
    name: "Slerf NFT",
    image: "/images/hotnft1.png",
  },
  {
    name: "Phaver-UP NFT",
    image: "/images/hotnft2.png",
  },
  {
    name: "Rune Store",
    image: "/images/hotnft3.png",
  },
  {
    name: "Rune Store2",
    image: "/images/hotnft4.png",
  },
];
export default function Home() {
  const isConnected = false;

  const handleAction = (e: any) => {
    if (isConnected) {
      return;
    }
    e.preventDefault();
  };

  return (
    <>
      <div>
        <div className="hero min-h-96">
          <div className="hero-content text-center">
            <div className="max-w-5xl">
              <div className="text-5xl font-bold flex gap-4">
                <span>You can</span>

                <Link
                  href="/me/borrow"
                  onClick={handleAction}
                  className="uppercase underline decoration-4 decoration-sky-500 transition transform hover:-translate-y-1 motion-reduce:transition-none motion-reduce:hover:transform-none"
                >
                  Borrow
                </Link>

                <span className=" text-slate-700">or</span>

                <Link
                  href="/me/rentout"
                  onClick={handleAction}
                  className="uppercase underline decoration-4 decoration-pink-500 transition transform hover:-translate-y-1 motion-reduce:transition-none motion-reduce:hover:transform-none"
                >
                  Rent Out
                </Link>
                <span>NFTs.</span>
              </div>
              <p className="py-6 text-slate-500">
                Renft is a Secure and User-Friendly NFT Rental Marketplace
              </p>
            </div>
          </div>
        </div>

        {/* 热门 NFT 展示 */}
        <div>
          <div className="flex gap-12">
            {hotNFTs.map((item) => (
              <div
                key={item.name}
                className="cursor-pointer card hover:border-primary-500  hover:border hover:bg-primary-500 hover:-translate-y-1 hover:scale-110 duration-300"
              >
                <figure>
                  <Image
                    src={item.image}
                    alt=""
                    width={800}
                    height={400}
                    priority={false}
                  />
                </figure>
                <div className="card-body">
                  <div className="card-actions ">{item.name}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}
