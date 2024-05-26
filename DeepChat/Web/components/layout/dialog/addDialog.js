"use client";

import { handleAddDialog } from "@/redux/slice/pushSlice";
import { useDispatch, useSelector } from "react-redux";
import { Button, Dialog } from "@material-tailwind/react";
import { Poppins } from "next/font/google";
import { useState } from "react";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["200", "300", "400", "500", "600", "700", "800", "900"],
});

export default function AddDialog() {
  const user = useSelector((state) => state.push.user);
  const addDialog = useSelector((state) => state.push.addDialog);
  const dispatch = useDispatch();
  const [address, setAddress] = useState("");
  const [note, setNote] = useState("");

  const sendRequest = async () => {
    if (!address || !address.startsWith("0x") || address.length === "46") {
      alert("Invalid Address");
      return;
    }

    if (!note) {
      alert("Invalid Note");
      return;
    }

    await user.chat.send(address, {
      type: "Text",
      content: note,
    });
    setAddress("");
    setNote("");
    dispatch(handleAddDialog());
  };

  return (
    <Dialog
      open={addDialog}
      handler={() => {
        dispatch(handleAddDialog());
      }}
      className="outline-none bg-transparent flex items-center justify-center"
    >
      <div
        className={
          "w-[400px] border-[1px] border-white/30 rounded-3xl flex flex-col items-center p-5 pb-7 text-white " +
          poppins.className
        }
      >
        <h1 className="font-bold text-5xl">Add</h1>
        <h3>Contact</h3>
        <div className="w-full ">
          <p className="mt-5 font-semibold text-xl ml-1">Address</p>
          <input
            type="text"
            className="w-full border-[1px] border-white/30 bg-transparent rounded-xl p-2 outline-none mt-2"
            placeholder="Enter Address"
            onChange={(e) => {
              setAddress(e.target.value);
            }}
            value={address}
          />
          <p className="mt-5 font-semibold text-xl ml-1">Note</p>
          <textarea
            type="text"
            className="w-full border-[1px] border-white/30 bg-transparent rounded-xl p-2 outline-none mt-2"
            placeholder="Enter Note"
            onChange={(e) => {
              setNote(e.target.value);
            }}
            value={note}
          />
        </div>

        <Button
          size="lg"
          className="mt-5 w-full rounded-2xl"
          onClick={sendRequest}
        >
          Add
        </Button>
      </div>
    </Dialog>
  );
}
