const assert = require("node:assert/strict");
const test = require("node:test");
const { AuthService } = require("../src/modules/auth/auth.service");

test("Google login verifies the token and creates a CardVerse account", async () => {
  const createdUsers = [];
  const userModel = {
    async findOne() {
      return null;
    },
    async create(data) {
      createdUsers.push(data);
      return {
        id: "user-1",
        ...data,
        toSafeObject() {
          return { id: this.id, username: this.username, email: this.email };
        },
      };
    },
  };
  const oauthClient = {
    async verifyIdToken(options) {
      assert.equal(options.idToken, "verified-google-token");
      assert.deepEqual(options.audience, ["web-client-id"]);
      return {
        getPayload: () => ({
          sub: "google-user-1",
          email: "Darpan@Example.com",
          email_verified: true,
          name: "Darpan Chelani",
        }),
      };
    },
  };
  const service = new AuthService({
    oauthClient,
    userModel,
    audiences: ["web-client-id"],
    jwtSecret: "test-secret-that-is-long-enough",
  });

  const result = await service.loginWithGoogle({
    idToken: "verified-google-token",
  });

  assert.equal(createdUsers.length, 1);
  assert.deepEqual(createdUsers[0], {
    username: "Darpan_Chelani",
    email: "darpan@example.com",
    googleSubject: "google-user-1",
  });
  assert.equal(result.user.username, "Darpan_Chelani");
  assert.equal(typeof result.token, "string");
});

test("Google login rejects an ID token that cannot be verified", async () => {
  const service = new AuthService({
    oauthClient: {
      async verifyIdToken() {
        throw new Error("invalid token");
      },
    },
    userModel: {},
    audiences: ["web-client-id"],
    jwtSecret: "test-secret-that-is-long-enough",
  });

  await assert.rejects(
    service.loginWithGoogle({ idToken: "invalid" }),
    (error) => error.status === 401 && /could not be verified/.test(error.message),
  );
});
