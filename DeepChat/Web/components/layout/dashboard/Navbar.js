"use client";
import { Button } from "@material-tailwind/react";
import Avatar from "boring-avatars";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useAccount, useDisconnect } from "wagmi";
import { useSelector } from "react-redux";

export default function Navbar() {
  const { disconnect } = useDisconnect();
  const router = useRouter();
  const { address, connector } = useAccount();
  const [client, setClient] = useState(false);
  const stream = useSelector((state) => state.push.stream);

  useState(() => {
    setClient(true);
  }, []);

  return (
    client && (
      <div className="w-full flex items-center justify-between mt-5">
        <div className="flex justify-center items-center gap-4 rounded-2xl bg-gray-900 p-3 px-5">
          <Avatar
            size={40}
            name={address}
            variant="marble"
            colors={["#92A1C6", "#146A7C", "#F0AB3D", "#C271B4", "#C20D90"]}
          />
          <div className="flex flex-col">
            <h2
              className="text-lg text-white hover:cursor-pointer"
              onClick={() => {
                navigator.clipboard.writeText(address);
                alert("Copied to clipboard!");
              }}
            >
              {address
                ? address.slice(0, 4) + "..." + address.slice(-4)
                : "0x00...0000"}
            </h2>
            <h3 className="text-sm text-white/40">
              {connector && connector.name === "MetaMask"
                ? "Metamask"
                : "Coinbase"}
            </h3>
          </div>
        </div>

        <div className="flex flex-col items-center -ml-16">
          <h1 className="font-bold text-5xl">DeepChat</h1>
        </div>

        <Button
          className="h-full rounded-2xl normal-case"
          size="lg"
          onClick={() => {
            disconnect();
            if (stream) {
              stream.disconnect();
            }
            router.push("/");
          }}
        >
          Disconnect
        </Button>
      </div>
    )
  );
}
