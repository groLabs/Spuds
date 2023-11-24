/* eslint-disable @typescript-eslint/no-explicit-any*/

export enum GameReducerKind {
  ADD_PLAYER = "ADD_PLAYER",
  ADD_PLAYERS = "ADD_PLAYERS",
  SET_TURN = "SET_TURN",
  SET_CURRENT_OWNER = "SET_CURRENT_OWNER",
  SET_WINNER = 'SET_WINNER',
  SET_CLAIM_LOADING = 'SET_CLAIM_LOADING',
  SET_CAN_CLAIM = 'SET_CAN_CLAIM',
  SET_GAME_STARTED = 'SET_GAME_STARTED',
  SET_GAME_END_DATE = 'SET_GAME_END_DATE',
  SET_CAN_MINT = 'SET_CAN_MINT',
  SET_MINT_LOADING = "SET_MINT_LOADING",
  SET_HAS_MINTED = "SET_HAS_MINTED"
}

export interface GameAction {
  type: GameReducerKind;
  payload: any;
}

export interface ContextValue {
  state: InitialState;
  dispatch: React.Dispatch<GameAction>;
}

export interface InitialState {
  players: string[];
  turn: number;
  currentOwner: string;
  winner: string;
  claimLoading: boolean;
  gameStarted: boolean;
  gameEndDate: number;
  canMint: boolean;
  mintLoading: boolean;
  hasMinted: boolean;
}
