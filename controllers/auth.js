const { Router } = require("express");
const dotenv = require("dotenv");

dotenv.config();

const router = Router();

const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;

const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

router.post("/signIn", async (req, res) => {
  try {
    const email = req.body["email"];
    const password = req.body["password"];
    const name = req.body["name"];

    const user = await prisma.user.create({
      data: {
        email,
        password,
        name,
      },
    });

    return res.status(201).json(user);
  } catch (error) {
    console.log(error);
    return res.status(400).json(error);
  }
});

router.post("/login", async (req, res) => {
  const email = req.body["email"];
  const password = req.body["password"];

  if (!email || !password) {
    return res.status(400).json({ message: "email and password required" });
  }

  const dbUser = await prisma.user.findFirst({
    where: {
      email,
    },
  });

  if (!dbUser) {
    return res.status(400).json({
      message: "No user found!",
    });
  }

  if (password.toString() !== dbUser.password.toString()) {
    return res.status(400).json({ message: "wrong password!" });
  }

  const token = jwt.sign({ name: dbUser.name }, JWT_SECRET);

  return res.json({ token, user: dbUser.name });
});

module.exports = router;
