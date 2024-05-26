import AddDialog from "@/components/layout/dialog/addDialog";
import { LoginDialog } from "@/components/layout/dialog/loginDialog";

export const metadata = {
  title: "DeepChat | Dashboard",
  description: "DeepChat",
};

export default function RootLayout({ children }) {
  return (
    <div className="h-screen w-screen flex justify-center">
      {children}
      <LoginDialog />
      <AddDialog />
    </div>
  );
}
