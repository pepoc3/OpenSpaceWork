import Link from "next/link"

export default function Footer(){
   return  <footer className="footer footer-center gap-y-0 p-2 text-base-content text-slate-500">
   <nav className="grid-flow-col gap-4 ">
     <Link href="/about" className="link-hover">About us</Link>  
     <a className="link link-hover">Contact</a>
     <a className="link link-hover">Jobs</a>
     <a className="link link-hover" href="https://github.com/OpenSpace100/blockchain-tasks" >Github</a>
   </nav>
   <aside className="p-2">
     <p className="">Copyright © 2024 - All right reserved by Openspace</p>
   </aside>
 </footer>
}