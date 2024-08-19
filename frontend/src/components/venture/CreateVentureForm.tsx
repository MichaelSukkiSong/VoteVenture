"use client";

import { ethers } from "ethers";
import { useState, useEffect } from "react";
import { ventureFactoryABI } from "@/utils/abi";
import { ventureFactoryAddress } from "@/utils/address";
import { useRouter } from "next/navigation";
import { GoSync } from "../../utils/icons";

const CreateVentureForm = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [isLoading, setIsLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setSigner(provider.getSigner());
    } else {
      console.log("Please install MetaMask");
    }

    setIsLoading(false);
  }, []);

  const handleCreate = () => {
    console.log("Creating Venture...");

    if (signer) {
      async function createVenture() {
        setIsLoading(true);

        try {
          const ventureFactoryContract = new ethers.Contract(
            ventureFactoryAddress,
            ventureFactoryABI,
            signer
          );

          await ventureFactoryContract.createVenture();

          router.push("/");
        } catch (e) {
          console.log(e);
        }
        setIsLoading(false);
      }

      createVenture();
    }
  };

  return (
    <div>
      <div className="mb-4">Would you like to create a new Venture?</div>
      <div>
        <button
          onClick={handleCreate}
          className="bg-blue-500 text-white border border-blue-800 rounded-sm px-4 py-2 w-28 h-12"
          disabled={isLoading}
        >
          {isLoading ? (
            <GoSync className="animate-spin w-full h-4/5" />
          ) : (
            <span>Create</span>
          )}
        </button>
      </div>
    </div>
  );
};

export default CreateVentureForm;
