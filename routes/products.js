const express = require("express");
const router = express.Router();
const productsController = require("../controllers/productsController");

// Route to get all products
router.get("/", productsController.getAllProducts);

// Route to get a product by ID
router.get("/:id", productsController.getProductById);

// Route to create a new product
router.post("/", productsController.createProduct);

// Route to update a product by ID
router.put("/:id", productsController.updateProduct);

// Route to delete a product by ID
router.delete("/:id", productsController.deleteProduct);

module.exports = router;
