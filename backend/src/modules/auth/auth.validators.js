const { body } = require("express-validator");

const googleValidators = [
  body("idToken")
    .isString()
    .withMessage("Google ID token is required")
    .isLength({ min: 1, max: 10000 })
    .withMessage("Google ID token is invalid"),
];

module.exports = { googleValidators };
