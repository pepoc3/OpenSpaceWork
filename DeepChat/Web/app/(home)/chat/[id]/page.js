"use client";

import Navbar from "@/components/layout/dashboard/Navbar";
import { Button } from "@material-tailwind/react";
import {
  ArrowRightEndOnRectangleIcon,
  PaperAirplaneIcon,
} from "@heroicons/react/24/solid";
import Avatar from "boring-avatars";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { useSelector } from "react-redux";
import { useEffect } from "react";
import { useAccount } from "wagmi";
import ChatBubble from "@/components/layout/chat/ChatBubble";

export default function Chat({ params }) {
  const router = useRouter();
  const user = useSelector((state) => state.push.user);
  const [message, setMessage] = useState("");
  const [history, setHistory] = useState([]);
  const { isConnected } = useAccount();
  const data = useSelector((state) => state.push.data);

  useEffect(() => {
    if (user && isConnected) {
      fetchHistory();
    }
  }, [user, isConnected]);

  useEffect(() => {
    if (data && user && isConnected) {
      fetchHistory();
    }
  }, [data]);

  const fetchHistory = async () => {
    const history = await user.chat.history(params.id.replace("%3A", ":"));
    setHistory(history);
  };

  const sendMessage = async () => {
    await user.chat.send(params.id.replace("%3A", ":"), {
      type: "Text",
      content: message,
    });
    setMessage("");
    fetchHistory();
  };

  return (
    <div className="w-[1024px] h-screen flex flex-col items-center">
      <Navbar />

      <div className="w-full flex items-center justify-between gap-4 rounded-2xl bg-gray-900 p-3 px-5 mt-5">
        <div className="flex gap-4 items-center">
          <Avatar
            size={40}
            name={params.id.split("%3A")[1]}
            variant="marble"
            colors={["#92A1C6", "#146A7C", "#F0AB3D", "#C271B4", "#C20D90"]}
          />
          <div className="flex flex-col">
            <h2 className="text-lg text-white">{params.id.split("%3A")[1]}</h2>
            <h3 className="text-sm text-white/40">Chats</h3>
          </div>
        </div>
        <div className="flex gap-4 items-center">
          <Button
            size="lg"
            className="rounded-2xl flex items-center justify-center gap-2 bg-gray-800"
            onClick={() => {
              router.push("/dashboard");
            }}
          >
            <ArrowRightEndOnRectangleIcon className="h-4 w-4 -mt-0.5" />
            Back
          </Button>
        </div>
      </div>

      <div className="w-full h-full flex flex-col-reverse items-center gap-3 mt-5">
        <div className="w-full flex items-center justify-between gap-4 rounded-2xl bg-gray-900 p-3 px-5 mb-5">
          <input
            type="text"
            className="w-full h-full bg-gray-900 text-white/80 outline-none"
            placeholder="Type your message here"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
          ></input>
          <Button
            size="lg"
            className="rounded-2xl flex items-center justify-center gap-2 px-5 bg-blue-400"
            disabled={message === ""}
            onClick={() => {
              sendMessage();
            }}
          >
            <PaperAirplaneIcon className="h-6 w-6 -mt-0.5" />
          </Button>
        </div>
        <div className="w-full flex-grow flex relative">
          <div className="w-full h-full flex flex-col-reverse gap-2 overflow-auto absolute">
            {history.map((message, index) => (
              <ChatBubble
                key={index}
                message={message.messageContent}
                isMe={message.fromDID.split(":")[1] === user.account}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
