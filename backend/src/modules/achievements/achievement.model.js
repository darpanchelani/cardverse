const ACHIEVEMENTS = Object.freeze([
  ["first_online_win", "First Online Win", 50, 25],
  ["online_high_card_winner", "Online High Card Winner", 100, 50],
  ["online_war_winner", "Online War Winner", 150, 75],
  ["online_blackjack_winner", "Online Blackjack Winner", 200, 100],
  ["five_online_wins", "Five Online Wins", 250, 100],
  ["ten_total_wins", "Ten Total Wins", 300, 150],
  ["coin_collector", "Coin Collector", 500, 200],
  ["level_5_player", "Level 5 Player", 300, 150],
].map(([id, title, rewardCoins, rewardXp]) => ({
  id,
  title,
  rewardCoins,
  rewardXp,
})));

module.exports = { ACHIEVEMENTS };
