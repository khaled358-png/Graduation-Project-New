const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;

// In-memory orders (example only)
const orders = [];

// Serve static files from "public" folder
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json()); // parse application/json

// Simple API endpoint to receive orders
app.post('/api/order', (req, res) => {
  const { name, phone, items, notes } = req.body || {};
  if (!name || !phone || !Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ success: false, message: 'Invalid order payload' });
  }

  const order = {
    id: orders.length + 1,
    name,
    phone,
    items,
    notes: notes || '',
    createdAt: new Date().toISOString()
  };

  orders.push(order);
  console.log('New order:', order);
  return res.json({ success: true, orderId: order.id });
});

// Endpoint to view orders (for demo only)
app.get('/api/orders', (req, res) => {
  res.json({ success: true, count: orders.length, orders });
});

// Start the server
app.listen(PORT, () => {
  console.log(`Restaurant site running on http://localhost:${PORT}`);
});

