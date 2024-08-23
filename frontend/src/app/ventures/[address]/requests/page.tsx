"use client";

import { useEffect, useState } from "react";
import { usePathname } from "next/navigation";
import Link from "next/link";
import VentureRequestShow from "@/components/venture/VentureRequestShow";

const VentureRequestsPage = () => {
  const [ventureContractAddress, setVentureContractAddress] =
    useState<string>("");
  const pathname = usePathname();

  useEffect(() => {
    if (pathname) {
      setVentureContractAddress(
        pathname.replace("/ventures/", "").replace("/requests", "")
      );
    }
  }, [pathname]);

  return (
    <div className="grid md:grid-cols-4 grid-cols-1 min-h-screen py-16 gap-4">
      <div className="col-span-3">
        <VentureRequestShow />
      </div>
      <div className=" flex justify-end items-start ">
        <Link href={`/ventures/${ventureContractAddress}/requests/new`}>
          <button className="bg-sky-600 text-white px-4 py-2 text-lg rounded-sm w-48">
            Add Request
          </button>
        </Link>
      </div>
    </div>
  );
};

export default VentureRequestsPage;
