import "./App.css";
import { Typography } from "@mui/material";
import { configureChains, mainnet, createConfig, WagmiConfig } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import { publicProvider } from "wagmi/providers/public";
import { CoinbaseWalletConnector } from "wagmi/connectors/coinbaseWallet";
import { WalletConnectConnector } from "wagmi/connectors/walletConnect";
import { ConnectWallet } from "./wallet/ConnectWallet";
import { GameProvider } from "./game/GameProvider";
import { JoinGame } from "./game/JoinGame";

const { chains, publicClient, webSocketPublicClient } = configureChains(
  [mainnet],
  [publicProvider()]
);

const config = createConfig({
  autoConnect: true,
  publicClient,
  webSocketPublicClient,
  connectors: [
    new InjectedConnector({ chains }),
    new WalletConnectConnector({
      chains,
      options: {
        projectId: "766e6ad1eb4e8109f29eb496fc480e62",
      },
    }),
    new CoinbaseWalletConnector({
      chains,
      options: {
        appName: "spud",
        jsonRpcUrl:
          "https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      },
    }),
  ],
});

function App() {
  return (
    <WagmiConfig config={config}>
      <GameProvider>
        <>
          <Typography>Hello</Typography>
          <ConnectWallet />
          <JoinGame />
        </>
      </GameProvider>
    </WagmiConfig>
  );
}

export default App;
