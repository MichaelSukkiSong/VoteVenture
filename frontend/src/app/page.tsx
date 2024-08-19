import Link from "next/link";
import VentureList from "@/components/venture/VentureList";

export default function Home() {
  return (
    <main className="grid md:grid-cols-4 grid-cols-1 min-h-screen py-16 gap-4">
      <div className="col-span-3">
        <VentureList />
      </div>
      <div className=" flex justify-end items-start ">
        <Link href="/ventures/new">
          <button className="bg-sky-600 text-white px-4 py-2 text-lg rounded-sm w-48">
            Create Venture
          </button>
        </Link>
      </div>
    </main>
  );
}
