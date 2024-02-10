const express = require("express");
const app = express();

const cors = require("cors");

app.use(cors());

app.use(express.json());

const authController = require("./controllers/auth");

app.use("/auth", authController);

app.use("/", (req, res) => {
  res.send("working");
});

app.listen(3000, () => {
  console.log("server running on PORT 3000");
});
