function notFoundMiddleware(request, response) {
  response.status(404).json({
    success: false,
    message: `Route not found: ${request.method} ${request.originalUrl}`,
    errors: [],
  });
}

function errorMiddleware(error, _request, response, _next) {
  if (error?.code === 11000) {
    const field = Object.keys(error.keyPattern || error.keyValue || {})[0];
    return response.status(409).json({
      success: false,
      message: `${field || "Account"} already exists`,
      errors: [],
    });
  }
  const status = error.status || 500;
  return response.status(status).json({
    success: false,
    message: status >= 500 ? "Something went wrong" : error.message,
    errors: error.errors || [],
  });
}

module.exports = { notFoundMiddleware, errorMiddleware };
