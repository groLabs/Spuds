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
  const styles = {
    wrap: css`
      width: 296px;
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
    `,
    statusBox: css`
      padding: 14px 10px;
      background: rgba(51, 33, 27, 0.7);
      backdrop-filter: blur(10px);
      border-radius: 12px;
    `,
    typography: css`
      color: #ffbd5b;
      font-weight: 600;
      text-align: left;
    `,
    button: css`
      border-radius: 4px;
      background: #ffbd5b;
      height: 54px;
      color: black;
      text-transform: none;
      font-weight: 600;
      &:hover {
        background: #ffbd5b;
        opacity: 0.7;
      }
    `,
  };

  const buttonText = useMemo(() => {
    switch (status) {
      case PotatoStatus.canSteal:
        return "Steal";
      case PotatoStatus.claimable:
        return "Claim prize";
      case PotatoStatus.mintFresh:
        return "Minth fresh potato";
      default:
        break;
    }
  }, [status]);

  useEffect(() => {}, []);

  return (
    <Box css={styles.wrap}>
      <Box css={styles.statusBox}>
        {status !== PotatoStatus.mintFresh && (
          <>
            <Typography mb={0.5} css={styles.typography}>
              Prize: ${prize}
            </Typography>
            <Typography mb={1.5} css={styles.typography}>
              Plays: {plays}
            </Typography>
          </>
        )}
        <Button variant="contained" fullWidth css={styles.button}>
          {buttonText}
        </Button>
      </Box>
    </Box>
  );
}
