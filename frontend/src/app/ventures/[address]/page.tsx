"use client";

import { ethers } from "ethers";
import { usePathname, useRouter } from "next/navigation";
import { useState, useEffect } from "react";
import { ventureABI } from "@/utils/abi";
import VentureShow from "@/components/venture/VentureShow";
import { GoSync } from "../../../utils/icons";

const ShowVenturePage = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [ventureContractAddress, setVentureContractAddress] =
    useState<string>("");
  const [fundValue, setFundValue] = useState<number>(0);
  const [isLoading, setIsLoading] = useState(false);
  const pathname = usePathname();
  const router = useRouter();

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

  const handleFundClick = () => {
    console.log("Funding Venture...");

    if (signer) {
      async function fundVenture() {
        setIsLoading(true);

        try {
          const ventureContract = new ethers.Contract(
            ventureContractAddress,
            ventureABI,
            signer
          );

          await ventureContract.fund({
            value: ethers.utils.parseEther(fundValue.toString()),
          });
          console.log("Funding Completed...");

          router.refresh();
        } catch (e) {
          console.log(e);
        }

        setIsLoading(false);
      }

      fundVenture();
    }
  };

  return (
    <main className="grid md:grid-cols-4 grid-cols-1 min-h-screen py-16 gap-4 ">
      <div className="col-span-3">
        <VentureShow />
      </div>
      <div className=" flex flex-col px-10 py-14">
        <div className="mb-4 text-xl">Fund this Venture!</div>
        <input
          type="number"
          min="0"
          className="mb-4 h-10 outline outline-1 rounded-sm p-1 w-60"
          placeholder="Enter amount to fund (ether)"
          value={fundValue}
          onChange={(e) => setFundValue(parseFloat(e.target.value))}
        />
        <button
          onClick={handleFundClick}
          className="bg-sky-600 text-white px-4 py-2 text-lg rounded-sm w-28 h-12"
        >
          {isLoading ? (
            <GoSync className="animate-spin w-full h-4/5" />
          ) : (
            <span>Fund</span>
          )}
        </button>
      </div>
    </main>
  );
};

export default ShowVenturePage;
