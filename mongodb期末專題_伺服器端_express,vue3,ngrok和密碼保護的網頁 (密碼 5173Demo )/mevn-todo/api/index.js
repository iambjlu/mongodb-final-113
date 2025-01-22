var express = require("express");
var MongoClient = require("mongodb").MongoClient;
var cors = require("cors");
var bodyParser = require("body-parser");
const multer = require("multer");

var app = express();
app.use(cors());
app.use(bodyParser.json()); // 用於解析 application/json
app.use(bodyParser.urlencoded({ extended: true })); // 用於解析 application/x-www-form-urlencoded

var CONNECTION_STRING = "mongodb://127.0.0.1:27017";
var DATABASENAME = "todoappdb";
var database;

app.listen(5038, () => {
  MongoClient.connect(CONNECTION_STRING, (error, client) => {
    if (error) {
      console.error("Mongo DB Connection Error", error);
    } else {
      database = client.db(DATABASENAME);
      console.log("Mongo DB Connection Successful");
    }
  });
});

app.get('/api/todoapp/GetNote', (request, response) => {
  database.collection("todoappcollection").find({}).toArray((error, result) => {
    if (error) {
      response.status(500).send(error);
    } else {
      response.send(result);
    }
  });
});

app.post('/api/todoapp/AddNote', multer().none(), (request, response) => {
  database.collection("todoappcollection").count({}, function (error, numOfDocs) {
    if (error) {
      response.status(500).send(error);
    } else {
      var currentTime = new Date().toLocaleString("zh-TW", {timeZone: "Asia/Taipei"}); // 獲取當前時間
      database.collection("todoappcollection").insertOne({
        id: (numOfDocs + 1).toString(),
        description: request.body.newNotes,
        importance: ["重要性:"+request.body.importance,"緊急程度:"+request.body.urgency], // 使用矩陣
        lastModified: currentTime // 新增的屬性
      }, (err, result) => {
        if (err) {
          response.status(500).send(err);
        } else {
          response.json("新增成功");
        }
      });
    }
  });
});

app.delete('/api/todoapp/DeleteNote', (request, response) => {
  database.collection("todoappcollection").deleteOne({
    id: request.query.id
  }, (err, result) => {
    if (err) {
      response.status(500).send(err);
    } else {
      // Recalculate IDs after deletion
      database.collection("todoappcollection").find({}).toArray((error, notes) => {
        if (error) {
          response.status(500).send(error);
        } else {
          notes.forEach((note, index) => {
            database.collection("todoappcollection").updateOne(
              { _id: note._id },
              { $set: { id: (index + 1).toString() } }
            );
          });
          response.json("刪除成功");
        }
      });
    }
  });
});

app.put('/api/todoapp/UpdateNote', multer().none(), (request, response) => {
  const noteId = request.body.id;
  const newDescription = request.body.newDescription;
  const newImportance = ["重要性:"+request.body.importance,"緊急程度:"+request.body.urgency];
  const lastModified = new Date().toLocaleString("zh-TW", {timeZone: "Asia/Taipei"}); // 新增的屬性

  database.collection("todoappcollection").updateOne(
    { id: noteId },
    { $set: { description: newDescription, importance: newImportance, lastModified: lastModified } }, // 更新待辦事項時添加最後修改時間
    (err, result) => {
      if (err) {
        response.status(500).send(err);
      } else {
        response.json("編輯成功");
      }
    }
  );
});
