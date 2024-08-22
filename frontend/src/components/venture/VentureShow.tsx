"use client";

import { ethers } from "ethers";
import { usePathname } from "next/navigation";
import { useState, useEffect } from "react";
import { ventureABI } from "@/utils/abi";
import Link from "next/link";

const VentureShow: React.FC = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [ventureContractAddress, setVentureContractAddress] =
    useState<string>("");
  const pathname = usePathname();
  const [ventureDetails, setVentureDetails] = useState({
    balance: "",
    minimum_fund: "",
    requests: "",
    funders: "",
    entrepreneur: "",
  });

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setSigner(provider.getSigner());
    } else {
      console.log("Please install MetaMask");
    }
  }, []);

  useEffect(() => {
    if (pathname) {
      setVentureContractAddress(pathname.replace("/ventures/", ""));
    }
  }, [pathname]);

  useEffect(() => {
    if (signer) {
      async function fetchData() {
        try {
          const ventureContract = new ethers.Contract(
            ventureContractAddress,
            ventureABI,
            signer
          );

          const ventureDetails = await ventureContract.getVentureSummary();

          setVentureDetails({
            balance: ethers.utils.formatEther(ventureDetails[0]),
            minimum_fund: ethers.utils.formatEther(ventureDetails[1]),
            requests: ventureDetails[2].toString(),
            funders: ventureDetails[3].toString(),
            entrepreneur: ventureDetails[4].toString(),
          });
        } catch (e) {
          console.log(e);
        }
      }

      fetchData();
    }
  }, [signer]);

  const renderVentureDetails = () => {
    return (
      <div className="grid grid-cols-2 gap-4">
        <div className="border border-black p-4 col-span-1">
          <div className="text-xl mb-1">
            {ventureDetails.entrepreneur.slice(0, 15)}...
          </div>
          <div className="text-zinc-400 mb-2">Address of Entrupreneur</div>
          <div className="text-sm">
            The entrepreneur created this venture and can create requests to
            withdraw money
          </div>
        </div>
        <div className="border border-black p-4 col-span-1">
          <div className="text-xl mb-1">{ventureDetails.balance}</div>
          <div className="text-zinc-400 mb-2">Venture Balance (ethers)</div>
          <div className="text-sm">
            The balance is how much money this Venture has left to spend
          </div>
        </div>
        <div className="border border-black p-4 col-span-1">
          <div className="text-xl mb-1">{ventureDetails.minimum_fund}</div>
          <div className="text-zinc-400 mb-2">Minimum Fund (dollars)</div>
          <div className="text-sm">
            You must fund at least this much dollar to become a funder
          </div>
        </div>
        <div className="border border-black p-4 col-span-1">
          <div className="text-xl mb-1">{ventureDetails.requests}</div>
          <div className="text-zinc-400 mb-2">Number of Requests</div>
          <div className="text-sm">
            A request tries to withdraw money from the contract. Requests must
            be approved by funders
          </div>
        </div>
        <div className="border border-black p-4 col-span-1">
          <div className="text-xl mb-1">{ventureDetails.funders}</div>
          <div className="text-zinc-400 mb-2">Number of Funders</div>
          <div className="text-sm">
            Number of people who have already funded to this venture
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="h-screen">
      <h1 className="text-2xl mb-4 font-bold">Venture Details</h1>
      <div>{renderVentureDetails()}</div>
      <div className="mt-10">
        <Link href={`/ventures/${ventureContractAddress}/requests`}>
          <button className="bg-sky-600 text-white px-4 py-2 text-lg rounded-sm w-48">
            View Requests
          </button>
        </Link>
      </div>
    </div>
  );
};

export default VentureShow;
