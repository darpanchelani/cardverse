const COSMETICS = Object.freeze({
  cardTheme: [
    ["classic", "Classic", 0],
    ["royal_gold", "Royal Gold", 500],
    ["neon_night", "Neon Night", 750],
    ["desert_thar", "Thar Desert", 1000],
    ["minimal_dark", "Minimal Dark", 400],
  ],
  tableTheme: [
    ["green_felt", "Green Felt", 0],
    ["royal_table", "Royal Table", 700],
    ["night_casino", "Night Casino", 900],
    ["desert_table", "Desert Table", 1000],
  ],
  avatarFrame: [
    ["default", "Default", 0],
    ["bronze", "Bronze", 250],
    ["silver", "Silver", 500],
    ["gold", "Gold", 800],
    ["champion", "Champion", 1200],
  ],
});

function cosmeticList() {
  return Object.fromEntries(
    Object.entries(COSMETICS).map(([type, items]) => [
      type,
      items.map(([id, name, price]) => ({ id, name, price, type })),
    ]),
  );
}

module.exports = { COSMETICS, cosmeticList };
