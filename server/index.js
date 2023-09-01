const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");

const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require("./models/document");
const { SocketAddress } = require("net");

const PORT = process.env.PORT | 3001;

const app = express();
var server = http.createServer(app);
var io = require("socket.io")(server);
const DB =
  "mongodb+srv://ombhusal:Narayanom123@googledoc.lfd7dcm.mongodb.net/?retryWrites=true&w=majority";

//REST API

// app.post("/api/signup", (req, res) => {});
app.use(express.json());
app.use(cors());

app.use(authRouter);
app.use(documentRouter);

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connection Success");
  })
  .catch((e) => {
    console.log(err);
  });

io.on("connection", (socket) => {
  socket.on("join", (documentId) => {
    socket.join(documentId);
    console.log("joinned!");
  });

  socket.on("typing", (data) => {
    socket.broadcast.to(data.room).emit("changes", data); //exclude centre
  });

  socket.on("save", (data) => {
    saveData(data);
    // io.to(); //send everone
    // socket.to(); //send only centre
  });
});

const saveData = async (data) => {
  let document = await Document.findById(data.room);
  document.content = data.delta;
  document = await document.save();
};



server.listen(PORT, "0.0.0.0", () => {
  console.log(`connected at port ${PORT}`);
});
