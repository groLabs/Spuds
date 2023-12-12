import React, { useEffect, useMemo } from "react";
import { Box, Button, Typography } from "@mui/material";
import { css } from "@emotion/react";
import potato from "../../assets/potato.png";
import potatoSack from "../../assets/potato-sack.png";
import { PotatoStatus } from "../game.types";

type PotatoProps = {
  prize: number;
  plays: number;
  status: PotatoStatus;
};

export function Potato({
  prize,
  plays,
  status,
}: PotatoProps): React.ReactElement {

  const color = useMemo(() => {
    switch (status) {
      case PotatoStatus.claimable:
        return plays === 0 ? "#8BF4C8" : "#F79BFF";
      default:
        return "#ffbd5b";
    }
  }, [status, plays]);

  const styles = {
    wrap: css`
      width: 296px;
      min-width: 296px;
      height: 400px;
      border-radius: 20px;
      background-image: url(${status === PotatoStatus.mintFresh
        ? potatoSack
        : potato});
      background-size: cover;
      background-position: center;
      display: flex;
      flex-direction: column;
      justify-content: flex-end;
      padding: 8px;
      box-sizing: border-box;
    `,
    statusBox: css`
      padding: 14px 10px;
      background: rgba(51, 33, 27, 0.7);
      backdrop-filter: blur(10px);
      border-radius: 12px;
    `,
    typography: css`
      color: ${color};
      font-weight: 500;
      text-align: left;
    `,
    button: css`
      border-radius: 4px;
      background: ${color};
      height: 40px;
      color: black;
      text-transform: none;
      font-weight: 500;
      &:hover {
        background: ${color};
        opacity: 0.7;
      }
    `,
  };

  const buttonText = useMemo(() => {
    switch (status) {
      case PotatoStatus.canSteal:
        return "Steal";
      case PotatoStatus.claimable:
        return "Claim reward";
      case PotatoStatus.mintFresh:
        return "Minth fresh potato";
      case PotatoStatus.lost:
      case PotatoStatus.holding:
        return "";
      default:
        break;
    }
  }, [status]);

  const topText = useMemo(() => {
    switch (status) {
      case PotatoStatus.canSteal:
        return "0x0000...0000 is holding";
      case PotatoStatus.claimable:
        return plays === 0 ? "You won!" : "You won!... But too early";
      case PotatoStatus.mintFresh:
        return "";
      case PotatoStatus.lost:
        return "0x0000...0000 beat you";
      case PotatoStatus.holding:
        return "You're holding";
      default:
        break;
    }
  }, [status, plays]);

  useEffect(() => {}, []);

  return (
    <Box css={styles.wrap}>
      <Box css={styles.statusBox}>
        {status !== PotatoStatus.mintFresh && (
          <>
            <Typography css={styles.typography}>{topText}</Typography>

            <Box display="flex">
              <Typography mr={1.5} css={styles.typography}>
                Plays: {plays}
              </Typography>
              <Typography css={styles.typography}>Prize: ${prize}</Typography>
            </Box>
          </>
        )}
        {![PotatoStatus.lost, PotatoStatus.holding].includes(status) && (
          <Button
            sx={{ mt: 1.5 }}
            variant="contained"
            fullWidth
            css={styles.button}
          >
            {buttonText}
          </Button>
        )}
      </Box>
    </Box>
  );
}
