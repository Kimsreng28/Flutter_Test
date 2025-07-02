const db = require("../config/db");

// Function to get all products from the database
exports.getAllProducts = async (req, res) => {
  try {
    const products = await db.query("SELECT * FROM Products");
    res.status(200).json(products);
  } catch (error) {
    console.error("Error fetching products:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Function to get a product by ID
exports.getProductById = async (req, res) => {
  const productId = req.params.id;
  try {
    const result = await db.query(
      "SELECT * FROM Products WHERE ProductID = @id",
      { id: productId }
    );

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.status(200).json(result.recordset[0]);
  } catch (error) {
    console.error("Error fetching product:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};

// Function to create a new product
exports.createProduct = async (req, res) => {
  try {
    const { productName, price, stock } = req.body;

    // Validation
    if (!productName || !price || !stock) {
      return res.status(400).json({ error: "All fields are required" });
    }
    if (price <= 0 || stock <= 0) {
      return res
        .status(400)
        .json({ error: "Price and stock must be positive values" });
    }

    const result = await db.query(
      `INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) 
       VALUES (@productName, @price, @stock);
       SELECT SCOPE_IDENTITY() AS id;`,
      { productName, price, stock }
    );

    const newProduct = {
      productId: result.recordset[0].id,
      productName,
      price,
      stock,
    };

    res.status(201).json(newProduct);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to update a product by ID
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { productName, price, stock } = req.body;

    // Validation
    if (!productName || !price || !stock) {
      return res.status(400).json({ error: "All fields are required" });
    }
    if (price <= 0 || stock <= 0) {
      return res
        .status(400)
        .json({ error: "Price and stock must be positive values" });
    }

    await db.query(
      `UPDATE PRODUCTS 
       SET PRODUCTNAME = '${productName}', PRICE = ${price}, STOCK = ${stock}
       WHERE PRODUCTID = ${id}`
    );

    res.status(200).json({ productId: id, productName, price, stock });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Function to delete a product by ID
exports.deleteProduct = async (req, res) => {
  const productId = req.params.id;
  try {
    const result = await db.query(
      `DELETE FROM Products WHERE ProductID = @id;`,
      { id: productId }
    );

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.status(200).json({ message: "Product deleted successfully" });
  } catch (error) {
    console.error("Error deleting product:", error);
    res.status(500).json({ message: "Internal server error" });
  }
};
