"use client";
import {
  ArrowLeftStartOnRectangleIcon,
  ChatBubbleBottomCenterTextIcon,
} from "@heroicons/react/24/solid";
import { Button } from "@material-tailwind/react";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { PushAPI, CONSTANTS } from "@pushprotocol/restapi";
import { useEthersSigner } from "@/wagmi/EthersSigner";
import { useDispatch, useSelector } from "react-redux";
import { setUser } from "@/redux/slice/pushSlice";
import { useRouter } from "next/navigation";
import usePush from "@/hooks/usePush";

export default function Home() {
  const { connect, connectors } = useConnect();
  const { isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const signer = useEthersSigner();
  const dispatch = useDispatch();
  const router = useRouter();
  const { streamChat } = usePush();
  const stream = useSelector((state) => state.push.stream);

  return (
    <div className="h-screen w-screen flex items-center justify-center bg-black">
      <div className="w-[400px] border-[1px] border-white/30 rounded-3xl flex flex-col items-center p-5 pb-7">
        <ChatBubbleBottomCenterTextIcon className="h-20 w-20 text-white mb-2" />
        <h1 className="font-bold text-5xl">DeepChat</h1>
        {/* <h3>Messenger</h3> */}

        {!isConnected && (
          <>
            <Button
              className="w-full mt-10 rounded-2xl"
              size="lg"
              onClick={() => {
                connect({
                  connector: connectors[0],
                });
              }}
            >
              Metamask
            </Button>
            <Button
              className="w-full mt-5 rounded-2xl"
              size="lg"
              onClick={() => {
                connect({
                  connector: connectors[1],
                });
              }}
            >
              Coinbase
            </Button>
          </>
        )}

        {isConnected && (
          <>
            <Button
              className="w-full mt-10 rounded-2xl flex items-center justify-center"
              size="lg"
              onClick={async () => {
                const user = await PushAPI.initialize(signer, {
                  env: CONSTANTS.ENV.PROD,
                });
                if (user) {
                  if (!user.readMode) {
                    dispatch(setUser(user));
                    streamChat(user);
                    router.push("/dashboard");
                  }
                }
              }}
            >
              Initiate Push{" "}
              <ChatBubbleBottomCenterTextIcon className="h-5 w-5 ml-1" />
            </Button>
            <Button
              className="w-full mt-5 rounded-2xl flex items-center justify-center"
              size="lg"
              onClick={() => {
                if (stream) stream.disconnect();
                disconnect();
              }}
            >
              Disconnect{" "}
              <ArrowLeftStartOnRectangleIcon className="h-5 w-5 ml-1 -mt-0.5" />
            </Button>
          </>
        )}
      </div>
    </div>
  );
}
