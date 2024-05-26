"use client";

import Chats from "@/components/layout/dashboard/Chats";
import Navbar from "@/components/layout/dashboard/Navbar";
import Requests from "@/components/layout/dashboard/Requests";
import {
  Tabs,
  TabsHeader,
  TabsBody,
  Tab,
  TabPanel,
} from "@material-tailwind/react";
import { Poppins } from "next/font/google";

const poppins = Poppins({
  subsets: ["latin"],
  weight: ["200", "300", "400", "500", "600", "700", "800", "900"],
});

export default function Dashboard() {
  return (
    <div className="w-[1024px] flex flex-col items-center">
      <Navbar />

      <Tabs value="Chats" className="mt-5 w-full">
        <TabsHeader
          className="h-[60px] rounded-2xl bg-gray-800"
          indicatorProps={{
            className: " shadow-none rounded-2xl bg-black",
          }}
        >
          <Tab value="Chats" className={"text-white " + poppins.className}>
            Chats
          </Tab>
          <Tab value="Requests" className={"text-white " + poppins.className}>
            Requests
          </Tab>
        </TabsHeader>

        <TabsBody>
          <TabPanel value="Chats" className="px-0">
            <Chats />
          </TabPanel>
          <TabPanel value="Requests" className="px-0">
            <Requests />
          </TabPanel>
        </TabsBody>
      </Tabs>
    </div>
  );
}
