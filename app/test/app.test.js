const request = require("supertest");
const app = require("../index");

jest.mock("../db", () => ({
  pool: { query: jest.fn().mockResolvedValue({ rows: [] }) },
  init: jest.fn().mockResolvedValue()
}));

describe("Basic Node.js Endpoints", () => {

  it("GET /health returns status ok", async () => {
    const res = await request(app).get("/health");
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe("ok");
  });

  it("GET /status returns uptime and hostname", async () => {
    const res = await request(app).get("/status");
    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("uptime");
    expect(res.body).toHaveProperty("hostname");
  });

  it("POST /process returns the payload", async () => {
    const payload = { task: "example" };
    const res = await request(app).post("/process").send(payload);
    expect(res.statusCode).toBe(200);
    expect(res.body.data).toEqual(payload);
  });

});