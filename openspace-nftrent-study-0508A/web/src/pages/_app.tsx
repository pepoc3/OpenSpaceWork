import type { AppProps } from "next/app";
import Layout from "@/components/layout";
import { ToastContainer } from "react-toastify";
import "@/styles/globals.css";
import "react-toastify/dist/ReactToastify.css";

import { config } from "@/config";
import Web3ModalProvider from "@/components/Web3ModalProvider";

// import { cookieToInitialState } from "wagmi";
export default function App({ Component, pageProps }: AppProps) {
  // const initialState = cookieToInitialState(config);
  return (
    <Web3ModalProvider>
      <Layout>
        <ToastContainer />
        <Component {...pageProps} />
      </Layout>
    </Web3ModalProvider>
  );
}
