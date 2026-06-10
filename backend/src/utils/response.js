function success(data = {}, message = "Success") {
  return { success: true, message, ...data };
}

function failure(message, code = "BAD_REQUEST") {
  return { success: false, message, code };
}

module.exports = { success, failure };
