import React, { createContext, useEffect, useReducer } from "react";
import {
  InitialState,
  GameAction,
  GameReducerKind,
  ContextValue,
} from "./GameReducer.types";

const initialState = {
  players: [],
  turn: 0,
  currentOwner: "",
  winner: "",
  claimLoading: false,
  canClaim: false,
  gameStarted: false,
  gameEndDate: 0,
  canMint: false,
  mintLoading: false,
  hasMinted: false,
};

const reducer = (state: InitialState, action: GameAction) => {
  switch (action.type) {
    case GameReducerKind.ADD_PLAYERS:
      return { ...state, players: action.payload };
    case GameReducerKind.ADD_PLAYER:
      return { ...state, players: [...state.players, action.payload] };
    case GameReducerKind.SET_TURN:
      return { ...state, turn: action.payload };
    case GameReducerKind.SET_CURRENT_OWNER:
      return { ...state, currentOwner: action.payload };
    case GameReducerKind.SET_WINNER:
      return { ...state, winner: action.payload };
    case GameReducerKind.SET_CLAIM_LOADING:
      return { ...state, claimLoading: action.payload };
    case GameReducerKind.SET_CAN_CLAIM:
      return { ...state, canClaim: action.payload };
    case GameReducerKind.SET_GAME_STARTED:
      return { ...state, gameStarted: action.payload };
    case GameReducerKind.SET_GAME_END_DATE:
      return { ...state, gameEndDate: action.payload };
    case GameReducerKind.SET_CAN_MINT:
      return { ...state, canMint: action.payload };
    case GameReducerKind.SET_MINT_LOADING:
      return { ...state, mintLoading: action.payload };
    case GameReducerKind.SET_HAS_MINTED:
      return { ...state, hasMinted: action.payload };
    default:
      return state;
  }
};

export const GameContext = createContext<ContextValue | null>(null);

export function GameProvider({
  children,
}: {
  children: React.ReactElement;
}): React.ReactElement {
  const [state, dispatch] = useReducer(reducer, initialState);

  useEffect(() => {}, []);

  return (
    <GameContext.Provider value={{ state, dispatch }}>
      {children}
    </GameContext.Provider>
  );
}
