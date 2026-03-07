const http = require("http");

const PORT = process.env.PORT || 3001;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ project: "project-b", status: "ok" }));
});

server.listen(PORT, () => {
  console.log(`project-b running on port ${PORT}`);
});
