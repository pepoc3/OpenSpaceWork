"use client";
import usePush from "@/hooks/usePush";
import { CheckIcon, XMarkIcon } from "@heroicons/react/24/solid";
import { Button } from "@material-tailwind/react";
import Avatar from "boring-avatars";

export default function RequestBox({ request }) {
  const { acceptRequest, rejectRequest } = usePush();
  return (
    <div className="w-full flex items-center justify-between gap-4 rounded-2xl bg-gray-900 p-3 px-5">
      <div className="flex gap-4 items-center">
        <Avatar
          size={40}
          name={request.did.split(":")[1]}
          variant="marble"
          colors={["#92A1C6", "#146A7C", "#F0AB3D", "#C271B4", "#C20D90"]}
        />
        <div className="flex flex-col">
          <h2 className="text-lg text-white">{request.did.split(":")[1]}</h2>
          <h3 className="text-sm text-white/40">
            {request.msg.messageContent}
          </h3>
        </div>
      </div>
      <div className="flex gap-4 items-center">
        <Button
          color="green"
          size="lg"
          className="rounded-2xl flex items-center justify-center gap-2"
          onClick={() => acceptRequest(request.wallets)}
        >
          <CheckIcon className="h-4 w-4 -mt-0.5" />
          Accept
        </Button>
        <Button
          color="red"
          size="lg"
          className="rounded-2xl flex items-center justify-center gap-2"
          onClick={() => rejectRequest(request.wallets)}
        >
          <XMarkIcon className="h-4 w-4 -mt-0.5" />
          Reject
        </Button>
      </div>
    </div>
  );
}
