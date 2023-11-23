import React, { useState } from "react";
import {
  Box,
  Button,
  Dialog,
  DialogTitle,
  List,
  ListItem,
  ListItemButton,
  Typography,
} from "@mui/material";
import { Connector, useAccount, useConnect } from "wagmi";
import { useDisconnect } from "wagmi";

export function ConnectWallet(): React.ReactElement {
  const [open, setOpen] = useState<boolean>(false);
  const { connectors, connect } = useConnect();
  const { address } = useAccount();
  const { disconnect } = useDisconnect();

  function onConnect(connector: Connector) {
    setOpen(false);
    connect({ connector });
  }

  return (
    <Box>
      <Dialog open={open} onClose={() => setOpen(false)}>
        <DialogTitle>Select your wallet provider</DialogTitle>
        <List>
          {connectors.map((connector) => (
            <ListItem key={connector.name}>
              <ListItemButton onClick={() => onConnect(connector)}>
                {connector.name}
              </ListItemButton>
            </ListItem>
          ))}
        </List>
      </Dialog>
      {address ? (
        <Typography>Connected with {address} </Typography>
      ) : (
        <Button variant="contained" onClick={() => setOpen(true)}>
          Connect wallet
        </Button>
      )}
      {address && (
        <Button onClick={() => disconnect()} variant="contained">
          Disconnect
        </Button>
      )}
    </Box>
  );
}
