"use client";

import { ethers } from "ethers";
import { useState, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { GoSync } from "../../../utils/icons";
import { ventureABI } from "@/utils/abi";

const CreateRequestForm = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [isLoading, setIsLoading] = useState(false);
  const [ventureContractAddress, setVentureContractAddress] =
    useState<string>("");
  const [inputValue, setInputValue] = useState<{
    description: string;
    amount: string;
    recipient: string;
  }>({
    description: "",
    amount: "",
    recipient: "",
  });
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setSigner(provider.getSigner());
    } else {
      console.log("Please install MetaMask");
    }

    setIsLoading(false);
  }, []);

  useEffect(() => {
    if (pathname) {
      const address = pathname.replace("/ventures/", "").split("/")[0];
      setVentureContractAddress(address);
    }
  }, [pathname]);

  const handleCreate = () => {
    console.log("Creating Request...");

    if (signer) {
      async function createRequest() {
        setIsLoading(true);

        try {
          const ventureContract = new ethers.Contract(
            ventureContractAddress,
            ventureABI,
            signer
          );

          await ventureContract.createRequest(
            inputValue.description,
            ethers.utils.parseEther(inputValue.amount),
            ethers.utils.getAddress(inputValue.recipient)
          );

          router.push(`/ventures/${ventureContractAddress}/requests`);
        } catch (e) {
          console.log(e);
        }
        setIsLoading(false);
      }

      createRequest();
    }
  };

  return (
    <div>
      <div className="mb-2">
        <label>Description</label>
        <div>
          <input
            value={inputValue.description}
            onChange={(e) =>
              setInputValue({ ...inputValue, description: e.target.value })
            }
            className="border border-gray-300 outline-none"
          />
        </div>
      </div>
      <div className="mb-2">
        <label>Amount in Ether</label>
        <div>
          <input
            value={inputValue.amount}
            onChange={(e) =>
              setInputValue({ ...inputValue, amount: e.target.value })
            }
            className="border border-gray-300 outline-none"
          />
        </div>
      </div>
      <div className="mb-2">
        <label>Recipient Address</label>
        <div>
          <input
            value={inputValue.recipient}
            onChange={(e) =>
              setInputValue({ ...inputValue, recipient: e.target.value })
            }
            className="border border-gray-300 outline-none"
          />
        </div>
      </div>

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

export default CreateRequestForm;
