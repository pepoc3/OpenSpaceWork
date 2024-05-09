import Navbar from "./navbar";
import Footer from "./footer";

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar /> 
      <main className="flex-grow grid grid-cols-8 gap-x-4 pb-10">
        <div className="col-start-2 col-span-6 mt-5">
          {children}
        </div>   
      </main>
      <Footer/>
    </div>
  );
}
