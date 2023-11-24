import React, { useContext, useMemo } from "react";
import { Button } from "@mui/material";
import { GameContext } from "./GameProvider";
import { useAccount } from "wagmi";
import { GameReducerKind } from "./GameReducer.types";

export function JoinGame(): React.ReactElement {
  const context = useContext(GameContext);
  const { address } = useAccount();

  function addToGame() {
    context?.dispatch({
      type: GameReducerKind.ADD_PLAYER,
      payload: address,
    });
  }

  const showButton = useMemo(() => {
    const hasJoined = !!(context?.state.players || []).find(
      (elem) => elem === address
    );
    return !hasJoined && address
  }, [context?.state.players, address]);

  return showButton ? <Button onClick={addToGame}>Join Game</Button> : <></>;
}
