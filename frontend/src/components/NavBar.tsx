import Link from "next/link";

const NavBar: React.FC = () => {
  return (
    <nav className="flex justify-between border-2 border-black h-14">
      <Link href="/" className="flex justify-center items-center">
        <div className="h-full flex justify-center items-center px-5 border-r-2 border-black">
          <span>VoteVenture</span>
        </div>
      </Link>

      <div className="flex">
        <Link href="/" className="flex justify-center items-center">
          <div className="h-full px-5 flex items-center justify-center border-l-2 border-r-2 border-black">
            <span>Ventures</span>
          </div>
        </Link>
        <Link href="/ventures/new" className="flex justify-center items-center">
          <div className="w-14 flex justify-center items-center">
            <button className="w-full h-full">+</button>
          </div>
        </Link>
      </div>
    </nav>
  );
};

export default NavBar;
