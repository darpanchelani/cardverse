const { body } = require("express-validator");

const registerValidators = [
  body("username")
    .trim()
    .isLength({ min: 3, max: 20 })
    .withMessage("Username must be 3 to 20 characters")
    .matches(/^[A-Za-z0-9_]+$/)
    .withMessage("Username can only contain letters, numbers, and underscores"),
  body("email")
    .trim()
    .isEmail()
    .withMessage("Enter a valid email address")
    .normalizeEmail(),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters"),
];

const loginValidators = [
  body("email").trim().isEmail().withMessage("Enter a valid email address"),
  body("password").notEmpty().withMessage("Password is required"),
];

module.exports = { registerValidators, loginValidators };
