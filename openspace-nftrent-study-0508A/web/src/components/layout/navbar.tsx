import { Fragment, useState, useEffect } from "react";
import Link from "next/link";
import {
  BuildingStorefrontIcon,
  UserCircleIcon,
  WalletIcon,
  MoonIcon,
  SunIcon,
  StarIcon,
  CameraIcon,
  BookOpenIcon,
} from "@heroicons/react/24/outline";

import ConnectButton from "@/components/ConnectButton";

export default function Navbar() {
  const isConnected = false;
  const isdark = true;
  const toggleDarkMode = () => {};

  return (
    <header>
      <div className="navbar bg-base-100">
        <div className="navbar-start">
          <div className="dropdown">
            <div tabIndex={0} role="button" className="btn btn-ghost lg:hidden">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M4 6h16M4 12h8m-8 6h16"
                />
              </svg>
            </div>
            <ul
              tabIndex={0}
              className="menu menu-sm dropdown-content mt-3 z-[1] p-2 shadow bg-base-100 rounded-box w-52"
            >
              <li>
                <a>
                  <BuildingStorefrontIcon className="h-6 w-6" />
                  Market
                </a>
              </li>
              <li>
                <a>Status</a>
              </li>
            </ul>
          </div>
          <Link href="/" className="text-xl font-bold uppercase">
            Renft
          </Link>
        </div>
        <div className="navbar-center hidden lg:flex">
          <ul className="menu menu-horizontal px-1">
            <li>
              <Link href="/mkt">
                <BuildingStorefrontIcon className="h-6 w-6" /> Market
              </Link>
            </li>
            {isConnected && (
              <li>
                <Link href="/me">
                  <WalletIcon className="h-6 w-6"></WalletIcon> Status
                </Link>
              </li>
            )}
            <li>
              <a>
                <StarIcon className="h-6 w-6" />
                Stake
              </a>
            </li>
            <li>
              <a>
                <BookOpenIcon className="h-6 w-6" />
                Governance
              </a>
            </li>
            <li>
              <a>
                <CameraIcon className="h-6 w-6" />
                Airdrop
              </a>
            </li>
          </ul>
        </div>
        <div className="navbar-end">
          <div className="px-5">
            <ConnectButton></ConnectButton>
          </div>
          <label className="swap swap-rotate">
            <input type="checkbox" checked={isdark} onChange={toggleDarkMode} />
            <SunIcon className="swap-off fill-current w-6 h-6" />
            <MoonIcon className="swap-on fill-current w-6 h-6" />
          </label>
        </div>
      </div>
    </header>
  );
}
