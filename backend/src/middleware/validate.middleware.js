const { validationResult } = require("express-validator");

function validateRequest(request, response, next) {
  const result = validationResult(request);
  if (result.isEmpty()) return next();
  return response.status(422).json({
    success: false,
    message: "Validation failed",
    errors: result.array().map((error) => ({
      field: error.path,
      message: error.msg,
    })),
  });
}

module.exports = { validateRequest };
