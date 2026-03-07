const http = require("http");

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ project: "project-a", status: "ok" }));
});

server.listen(PORT, () => {
  console.log(`project-a running on port ${PORT}`);
});
