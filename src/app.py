import random


class SpudGame:
    def __init__(
        self,
        players,
        total_numbers=20,
        initial_prize=10,
        pool_winner_percentage=0.8,
        max_fee=20,
        balances=100,
    ):
        self.players = {player: balances for player in players}
        self.players_initial_balance = self.players.copy()
        self.prize_pool = self.initial_prize = initial_prize
        self.total_numbers = total_numbers
        self.pool_winner_percentage = pool_winner_percentage
        self.available_numbers = set(range(total_numbers))
        self.spudmaster_number = random.randint(0, total_numbers)
        self.current_holder = random.choice(list(players))
        self.max_fee = max_fee
        self.steal_num = 0

    def start_game(self):
        print(
            f"*********** GAME START ****************\n"
            f"Initial prize pool: ${self.prize_pool}"
        )
        self._show_balances("Starting")

        while True:
            if not self._play_round():
                break

    def _play_round(self):
        """play a round"""
        if self._all_rekt():
            return False

        thief, thief_guess = self._choose_number()

        steal_fee = self._update_fee()

        self._charge_fee(thief, steal_fee)

        return self._check_result(thief, thief_guess, steal_fee)

    def _all_rekt(self):
        """checks if all users have enough balance"""
        if all(balance < 10 for balance in self.players.values()):
            print("All players have run out of money. Game ends without a winner.")
            return True
        return False

    def _choose_number(self):
        """choose random thief & number"""
        self.steal_num += 1
        thief = random.choice([p for p in self.players if p != self.current_holder])
        thief_guess = random.choice(list(self.available_numbers))
        self.available_numbers.remove(thief_guess)
        return thief, thief_guess

    def _update_fee(self):
        """Dynamic steal fee related to the chances of winning"""
        # Base fee
        base_fee = 2

        # Increases on each steal
        dynamic_fee = (self.total_numbers - len(self.available_numbers)) * 0.5

        # Increases with prize pool but has a maximum cap
        max_prize_pool_component = self.max_fee
        prize_pool_component = min(self.prize_pool * 0.01, max_prize_pool_component)

        # Calculate total fee
        return base_fee + dynamic_fee + prize_pool_component

    def _charge_fee(self, thief, steal_fee):
        """Deduct fee from thief's balance"""
        if self.players[thief] >= steal_fee:
            self.players[thief] -= steal_fee
            self.prize_pool += steal_fee
        else:
            print(f"{thief} doesn't have enough funds to steal the spud.")

    def _get_winner_reward(self):
        """
        Calculate the percentage based on remaining numbers:
        early winners get less pool prize (e.g.: avoid 1 steal and get 80% of pool)
        """
        remaining_numbers_percentage = len(self.available_numbers) / self.total_numbers
        winner_percentage = (
            1 - remaining_numbers_percentage
        ) * self.pool_winner_percentage
        # Ensure at least a 15% reward (eg: avoid negative result if 1st try winner)
        winner_percentage = max(winner_percentage, 0.15)
        return self.prize_pool * winner_percentage

    def _check_result(self, thief, thief_guess, steal_fee) -> bool:
        """Check player's choice"""
        if thief_guess == self.spudmaster_number or len(self.available_numbers) == 0:
            # Correct guess or it's the last steal
            self._show_round_result(thief, steal_fee)
            winner_reward = self._get_winner_reward()
            self._show_round_winner(thief, winner_reward)
            self.players[thief] += winner_reward
            self.prize_pool -= winner_reward
            print(f"Remaining prize pool for next game: ${self.prize_pool:.2f}")
            self._show_balances("Finished")
            return False
        else:
            # Wrong guess
            self._show_round_result(thief, steal_fee)
            self.current_holder = thief
            return True

    def _show_round_result(self, thief, steal_fee):
        print(
            f"{self.steal_num:>2} - {thief:<5} stole 🥔 from {self.current_holder:<5} -> {thief:>5} "
            f"balance: ${self.players[thief]:.2f}, Steal fee: ${steal_fee:.2f} "
            f", Prize pool: ${self.prize_pool:.2f}"
        )

    def _show_round_winner(self, thief, winner_reward):
        net_profit = winner_reward - (
            self.players_initial_balance[thief] - self.players[thief]
        )
        print(
            f"💥💥 Spud exploded 💥💥 "
            f"{thief} wins ${winner_reward:.2f} "
            f"(Net profit: {net_profit:.2f})"
        )

    def _show_balances(self, status: str):
        players_balances = ", ".join(
            [f"'{player}': ${balance:.2f}" for player, balance in self.players.items()]
        )
        print(f"{status} Spud Game with players: [{players_balances}]")


game = SpudGame(
    ["Alice", "Bob", "Mike"],
    total_numbers=20,  # total random numbers to choose from (1 to 20)
    initial_prize=100,  # initial prize pool in USD
    pool_winner_percentage=0.8,  # prize pool awarded to the winner; the rest will be carried over (not implemented)
    max_fee=20,  # maximum fee cost
    balances=100,  # initial user balances
)
game.start_game()
