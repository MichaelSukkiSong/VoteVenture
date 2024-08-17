"use client";

import { useEffect, useState } from "react";
import { ethers } from "ethers";
import NavBar from "./NavBar";

const Header: React.FC = () => {
  const [hasMetamask, setHasMetamask] = useState(false);
  const [isConnected, setIsConnected] = useState(false);
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);

  useEffect(() => {
    if (typeof window.ethereum !== "undefined") {
      setHasMetamask(true);
    }
  }, []);

  const handleConnect = async () => {
    if (typeof window.ethereum !== "undefined") {
      try {
        await ethereum.request({ method: "eth_requestAccounts" });
        setIsConnected(true);
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        setSigner(provider.getSigner());
        // console.log(signer);
      } catch (e) {
        console.log(e);
      }
    } else {
      setIsConnected(false);
    }
  };

  return (
    <div>
      <div className="flex justify-end py-1 mb-4">
        {hasMetamask ? (
          isConnected ? (
            <button
              disabled
              className="px-4 py-2 border border-black rounded-md"
            >
              Connected
            </button>
          ) : (
            <button
              onClick={handleConnect}
              className="px-4 py-2 border border-black rounded-md"
            >
              Connect to Wallet
            </button>
          )
        ) : (
          "Please install MetaMask"
        )}
      </div>
      <NavBar />
    </div>
  );
};

export default Header;
