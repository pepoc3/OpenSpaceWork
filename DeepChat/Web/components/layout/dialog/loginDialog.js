"use client";

import { Button, Dialog } from "@material-tailwind/react";
import { useState, useEffect } from "react";
import { useSelector } from "react-redux";
import { useAccount } from "wagmi";
import { ChatBubbleBottomCenterTextIcon } from "@heroicons/react/24/solid";
import { Poppins } from "next/font/google";
import { useRouter } from "next/navigation";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["200", "300", "400", "500", "600", "700", "800", "900"],
});

export function LoginDialog() {
  const [open, setOpen] = useState(false);
  const handleOpen = () => setOpen(!open);

  const user = useSelector((state) => state.push.user);
  const { isConnected } = useAccount();
  const router = useRouter();

  useEffect(() => {
    if (!user || !isConnected) {
      handleOpen();
    }
  }, [user, isConnected]);

  return (
    <>
      <Dialog
        open={open}
        handler={() => {}}
        className="outline-none bg-transparent flex items-center justify-center"
      >
        <div
          className={
            "w-[400px] border-[1px] border-white/30 rounded-3xl flex flex-col items-center p-5 pb-7 text-white " +
            poppins.className
          }
        >
          <ChatBubbleBottomCenterTextIcon className="h-20 w-20 text-white mb-2" />
          <h1 className="font-bold text-5xl">DeepChat</h1>
          {/* <h3>Messenger</h3> */}
          <p className="mt-5">Please connect your wallet to continue.</p>

          <Button
            className="w-full mt-5 rounded-2xl"
            size="lg"
            onClick={() => {
              router.push("/");
            }}
          >
            Connect
          </Button>
        </div>
      </Dialog>
    </>
  );
}
