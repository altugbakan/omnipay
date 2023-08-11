export default function Footer() {
  return (
    <footer className="footer footer-center p-4 text-base-content">
      <div className="flex flex-row">
        <a
          href="https://optimism.io"
          className="hover:scale-110"
          target="_blank"
        >
          <img src="/optimism.svg" alt="Optimism" className="w-6 h-6" />
        </a>
        <a href="https://base.org/" className="hover:scale-110" target="_blank">
          <img src="/base.svg" alt="Base" className="w-6 h-6" />
        </a>
        <p>
          Created for&nbsp;
          <a
            className="link link-hover font-semibold"
            href="https://ethglobal.com/events/superhack"
          >
            ETHGlobal Superhack
          </a>
        </p>
        <a href="https://zora.co" className="hover:scale-110" target="_blank">
          <img src="/zora.svg" alt="Zora" className="w-6 h-6" />
        </a>
        <a
          href="https://www.mode.network/"
          className="hover:scale-110"
          target="_blank"
        >
          <img src="/mode.svg" alt="Mode" className="w-6 h-6" />
        </a>
      </div>
    </footer>
  );
}
