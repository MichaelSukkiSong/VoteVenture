"use client";

import { ethers } from "ethers";
import { useState, useEffect } from "react";
import VentureItem from "./VentureItem";
import { ventureFactoryABI } from "@/utils/abi";
import { ventureFactoryAddress } from "@/utils/address";

const VentureList: React.FC = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [deployedContractsAddressArr, setDeployedContractsAddressArr] =
    useState<string[]>([]);

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      setSigner(provider.getSigner());
    } else {
      console.log("Please install MetaMask");
    }
  }, []);

  useEffect(() => {
    if (signer) {
      async function fetchData() {
        try {
          const ventureFactoryContract = new ethers.Contract(
            ventureFactoryAddress,
            ventureFactoryABI,
            signer
          );

          const deployedContractsAddressArr =
            await ventureFactoryContract.getDeployedVentures();

          setDeployedContractsAddressArr(deployedContractsAddressArr);
        } catch (e) {
          console.log(e);
        }
      }

      fetchData();
    }
  }, [signer]);

  const renderVentureItems = () => {
    return deployedContractsAddressArr.map((address, index) => {
      return <VentureItem key={index} address={address} />;
    });
  };

  return (
    <div className="h-screen">
      <h1 className="text-2xl mb-4 font-bold">Open Ventures</h1>
      <div>{renderVentureItems()}</div>
    </div>
  );
};

export default VentureList;
