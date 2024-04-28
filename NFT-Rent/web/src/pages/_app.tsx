import type { AppProps } from "next/app";
import Layout from "@/components/layout";
import { ToastContainer } from "react-toastify";
import "./styles/globals.css";
import "react-toastify/dist/ReactToastify.css";

export default function App({ Component, pageProps }: AppProps) {
  return (
    <Layout>
      <ToastContainer />
      <Component {...pageProps} />
    </Layout>
  );
}
