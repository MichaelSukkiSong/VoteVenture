import { ethers } from "ethers";
import { usePathname, useRouter } from "next/navigation";
import { useState, useEffect } from "react";
import { ventureABI } from "@/utils/abi";

const VentureRequestShow = () => {
  const [signer, setSigner] = useState<ethers.Signer | undefined>(undefined);
  const [ventureContractAddress, setVentureContractAddress] =
    useState<string>("");
  const [requests, setRequests] = useState<any>([]);
  const [funders, setFunders] = useState<any>([]);
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
      const address = pathname.replace("/ventures/", "").split("/")[0];
      setVentureContractAddress(address);
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

          const requestCount = await ventureContract.getRequestCount();
          const fundersArr = await ventureContract.getFunders();

          setFunders(fundersArr);

          if (requestCount > 0) {
            const requestArr = await Promise.all(
              Array.from(
                { length: requestCount.toNumber() },
                async (_, index) => {
                  const requestDescription =
                    await ventureContract.getRequestDescription(index);
                  const requestAmount = await ventureContract.getRequestAmount(
                    index
                  );
                  const requestRecipient =
                    await ventureContract.getRequestRecipient(index);
                  const requestApprovalCount =
                    await ventureContract.getRequestApprovalCount(index);

                  const requestComplete =
                    await ventureContract.getRequestComplete(index);

                  return {
                    id: index,
                    description: requestDescription,
                    amount: ethers.utils.formatEther(requestAmount),
                    recipient: requestRecipient,
                    approvalCount: requestApprovalCount.toNumber(),
                    complete: requestComplete,
                  };
                }
              )
            );

            setRequests(requestArr);
          }
        } catch (e) {
          console.log(e);
        }
      }

      fetchData();
    }
  }, [signer]);

  const handleApprove = async (index: number) => {
    const ventureContract = new ethers.Contract(
      ventureContractAddress,
      ventureABI,
      signer
    );

    await ventureContract.approveRequest(index);

    router.refresh();
  };

  const handleFinalize = async (index: number) => {
    const ventureContract = new ethers.Contract(
      ventureContractAddress,
      ventureABI,
      signer
    );

    await ventureContract.finalizeRequest(index);

    router.refresh();
  };

  const renderRequestRow = () => {
    return requests.map((request: any) => {
      const readyToFinalize = request.approvalCount > funders.length / 2;

      const rowClassName = () => {
        if (request.complete) {
          return "text-gray-300";
        } else if (readyToFinalize && !request.complete) {
          return "text-green-600 bg-green-100";
        }
      };

      return (
        <tr key={request.id} className={rowClassName()}>
          <td className="border border-slate-300 p-4">{request.id}</td>
          <td className="border border-slate-300 p-4">{request.description}</td>
          <td className="border border-slate-300 p-4">{request.amount}</td>
          <td className="border border-slate-300 p-4">
            {request.recipient.slice(0, 10)}...
          </td>
          <td className="border border-slate-300 p-4">
            {request.approvalCount} / {funders.length}
          </td>
          <td className="border border-slate-300 p-4">
            {request.complete ? null : (
              <button
                onClick={() => handleApprove(request.id)}
                className="bg-white border border-green-500 text-green-500 p-2 rounded-md"
              >
                Approve
              </button>
            )}
          </td>
          <td className="border border-slate-300 p-4">
            {request.complete ? null : (
              <button
                onClick={() => handleFinalize(request.id)}
                className="bg-white border border-cyan-500 text-cyan-500 p-2 rounded-md"
              >
                Finalize
              </button>
            )}
          </td>
        </tr>
      );
    });
  };

  return (
    <div className="h-screen">
      <h1 className="text-2xl mb-4 font-bold">Pending Requests</h1>
      <div className="mb-2">
        <table className="border border-collapse border-slate-400 table-auto">
          <thead>
            <tr>
              <th className="border border-slate-300 p-4">ID</th>
              <th className="border border-slate-300 p-4">Description</th>
              <th className="border border-slate-300 p-4">Amount</th>
              <th className="border border-slate-300 p-4">Recipient</th>
              <th className="border border-slate-300 p-4">Approval Count</th>
              <th className="border border-slate-300 p-4">Approve</th>
              <th className="border border-slate-300 p-4">Finalize</th>
            </tr>
          </thead>
          <tbody>{renderRequestRow()}</tbody>
        </table>
      </div>
      <div>Found {requests.length} Requests</div>
    </div>
  );
};

export default VentureRequestShow;
