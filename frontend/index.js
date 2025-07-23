const express = require('express');
const axios = require('axios');
const app = express();

app.get('/', async (req, res) => {
  try {
    const response = await axios.get('http://backend-poc:5000/');
    res.send(`Frontend → ${response.data}`);
  } catch (error) {
    res.send(`Error connecting to backend: ${error.message}`);
  }
});

app.listen(3000, () => {
  console.log('Frontend service running on port 3000');
});
