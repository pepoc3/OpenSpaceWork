export default function ChatBubble({ message, isMe }) {
  return isMe ? (
    <div className="flex flex-row-reverse w-full ">
      <div className="bg-blue-400 rounded-2xl p-3 px-5">
        <p>{message}</p>
      </div>
    </div>
  ) : (
    <div className="flex  w-full ">
      <div className="bg-gray-900 rounded-2xl p-3 px-5">
        <p>{message}</p>
      </div>
    </div>
  );
}
