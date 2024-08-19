import Link from "next/link";

interface VentureItemProps {
  address: string;
}

const VentureItem: React.FC<VentureItemProps> = ({ address }) => {
  return (
    <div className="border  p-4 rounded-lg border-gray-600 mb-4">
      <div className="font-bold">{address}</div>
      <div>
        <Link href={`/ventures/${address}`} className="text-blue-700">
          <button>View Venture</button>
        </Link>
      </div>
    </div>
  );
};

export default VentureItem;
