import Avatar from "boring-avatars";
import { useRouter } from "next/navigation";

export default function ChatBox({ chat }) {
  const router = useRouter();

  return (
    <div
      className="w-full flex items-center gap-4 rounded-2xl bg-gray-900 hover:bg-gray-800 transition-colors duration-300 hover:cursor-pointer p-3 px-5"
      onClick={() => {
        router.push(`/chat/${chat.did}`);
      }}
    >
      <Avatar
        size={40}
        name={chat.did.split(":")[1]}
        variant="marble"
        colors={["#92A1C6", "#146A7C", "#F0AB3D", "#C271B4", "#C20D90"]}
      />
      <div className="flex flex-col">
        <h2 className="text-lg text-white">{chat.did.split(":")[1]}</h2>
        <h3 className="text-sm text-white/40">{chat.msg.messageContent}</h3>
      </div>
    </div>
  );
}
