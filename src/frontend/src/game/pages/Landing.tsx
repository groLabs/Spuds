import React, { useState } from "react";
import { Box, Tab, Typography } from "@mui/material";
import { Potato } from "../components/Potato";
import { PotatoStatus } from "../game.types";
import { css } from "@emotion/react";
import { TabContext, TabList, TabPanel } from "@mui/lab";

const activeP = Array(8).fill(0)

export function Landing(): React.ReactElement {
  const [tab, setTab] = useState<string>("0");

  const styles = {
    title: css`
      color: #ffbd5b;
      font-size: 24px;
      font-weight: 600;
    `,
    wrap: css`
      margin-left: 124px;
      margin-top: 117px;
    `,
    tab: css`
      text-transform: none;
      font-size: 32px;
      font-weight: 600;

      &.MuiTab-root {
        color: #ffbd5b;
        opacity: 0.3;
      }
      &.Mui-selected {
        color: #ffbd5b;
        opacity: 1;
      }
    `,
    tabs: css`
      & .MuiTabs-indicator {
        display: none;
      }
    `,
  };

  const handleChange = (_event: React.SyntheticEvent, newValue: string) => {
    setTab(newValue);
  };


  return (
    <Box css={styles.wrap}>
      <TabContext value={tab}>
        <TabList css={styles.tabs} onChange={handleChange}>
          <Tab css={styles.tab} label="Active potatoes" value="0" />
          <Tab css={styles.tab} label="Potato sack" value="1" />
        </TabList>
        <TabPanel value="0">
          <Typography mb={3} css={styles.title}>
            Your potatoes
          </Typography>
          <Box mb={8.5} display="flex" gap={3} overflow="auto">
            {activeP.map((_potato, index) => (
              <Potato
                key={`active-${index}`}
                plays={10}
                prize={1000}
                status={PotatoStatus.lost}
              />
            ))}
          </Box>
          <Typography mb={3} css={styles.title}>
            All potatoes
          </Typography>
          <Box mb={8.5} display="flex" gap={3} overflow="auto">
            {activeP.map((_potato, index) => (
              <Potato
                key={`all-${index}`}
                plays={10}
                prize={1000}
                status={PotatoStatus.claimable}
              />
            ))}
          </Box>
        </TabPanel>
        <TabPanel value="1">
          <Box />
        </TabPanel>
      </TabContext>
    </Box>
  );
}
