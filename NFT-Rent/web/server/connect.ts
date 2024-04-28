// Require SQLite3 verbose module
import { verbose } from "sqlite3";

const sqlite3 = verbose();

// Connect to SQLite database, and if it doesn't exist, create it
const db = new sqlite3.Database(
  "./server/rentf.db",
  sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE,
  (err) => {
    // Error handling for connection
    if (err) {
      return console.error(err.message);
    } else {
      // Success message for successful connection
      console.log("Connected to the SQLite database.");
    }
  }
);

// Serialize runs to ensure sequential execution
db.serialize(() => {
  // Run SQL command to create table if it doesn't exist
  db.run(
    `CREATE TABLE IF NOT EXISTS orders (
            id INTEGER PRIMARY KEY,
            chainId INTEGER NOT NULL,
            taker TEXT,
            nftCA TEXT,
            tokenId INTEGER,
            nftName TEXT,
            nftImage TEXT,
            maxRentalDuration INTEGER,
            dailyRent INTEGER,
            minCollateral INTEGER,
            listEndTime INTEGER
            createdAt INTEGER
        )`,
    (err) => {
      // Error handling for table creation
      if (err) {
        return console.error(err.message);
      }
      console.log("Created orders table");
    }
  );
});
