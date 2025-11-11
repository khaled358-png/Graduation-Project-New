# My Restaurant Website

A simple Node.js and Express website for a restaurant, featuring a menu, contact page, and an order API. This project is containerized using Docker.

---

## Features

- Responsive web pages for:
  - Home
  - Menu
  - Contact
- Simple in-memory order management via API
- Containerized with Docker for easy deployment

---

## Tech Stack

- Node.js (v18+)
- Express.js
- HTML / CSS (public folder)
- Docker

---

## Project Structure

├── Dockerfile
├── README.md
├── dockerignore.
├── package.json
├── public/
│ ├── index.html
│ ├── menu.html
│ ├── contact.html
│ └── css/
│ └── style.css
└── server.js


---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/khaled358-png/Graduation-Project-New.git
cd Graduation-Project-New


docker build -t my-restaurant-site .


docker run -d -p 5050:3000 --name my-restaurant my-restaurant-site


Open your browser at http://localhost:5050

API Endpoints

POST /api/order - Create a new order

GET /api/orders - View all orders (for demo only)
