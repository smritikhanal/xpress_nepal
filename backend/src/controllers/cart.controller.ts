import { Request, Response } from 'express';
import Cart from '../models/Cart.js';
import Product from '../models/Product.js';
import { asyncHandler, sendResponse, ApiError } from '../utils/apiHelpers.js';

/**
 * @desc    Get current user's cart
 * @route   GET /api/cart
 * @access  Private
 */
export const getCart = asyncHandler(async (req: Request, res: Response) => {
  let cart = await Cart.findOne({ userId: req.user?.id })
    .populate('items.productId', 'title slug price discountPrice images stock');

  if (!cart) {
    // Create empty cart if doesn't exist
    cart = await Cart.create({ userId: req.user?.id, items: [] });
  }

  sendResponse(res, 200, cart);
});

/**
 * @desc    Add item to cart
 * @route   POST /api/cart/add
 * @access  Private
 */
export const addToCart = asyncHandler(async (req: Request, res: Response) => {
  const { productId, quantity = 1, attributes } = req.body;

  if (!productId) {
    throw new ApiError('Product ID is required', 400);
  }

  // Check if product exists and is in stock
  const product = await Product.findById(productId);
  if (!product) {
    throw new ApiError('Product not found', 404);
  }

  if (!product.isActive) {
    throw new ApiError('Product is not available', 400);
  }

  if (product.stock < quantity) {
    throw new ApiError('Insufficient stock', 400);
  }

  // Calculate price with attributes
  let finalPrice = product.discountPrice || product.price;

  // Validate and calculate attribute price modifiers
  if (attributes) {
    for (const [key, value] of Object.entries(attributes)) {
      // Check if attribute exists in product
      const attributeOptions = (product.attributes as any)?.[key];
      if (!attributeOptions) continue;

      // Find selected option
      const selectedOption = attributeOptions.find((opt: any) => opt.value === value);
      if (selectedOption) {
        finalPrice += selectedOption.priceModifier || 0;
      }
    }
  }

  // Find or create cart
  let cart = await Cart.findOne({ userId: req.user?.id });

  if (!cart) {
    cart = await Cart.create({
      userId: req.user?.id,
      items: [],
    });
  }

  // Helper to compare attributes maps
  const areAttributesEqual = (attr1: Map<string, string> | undefined, attr2: Record<string, string> | undefined) => {
    if (!attr1 && !attr2) return true;
    if (!attr1 || !attr2) return false;

    // Convert Mongoose Map to Object if needed, or iterate
    const keys1 = attr1 instanceof Map ? Array.from(attr1.keys()) : Object.keys(attr1);
    const keys2 = Object.keys(attr2);

    if (keys1.length !== keys2.length) return false;

    for (const key of keys1) {
      const val1 = attr1 instanceof Map ? attr1.get(key) : (attr1 as any)[key];
      const val2 = attr2[key];
      if (val1 !== val2) return false;
    }
    return true;
  };

  // Check if product with SAME attributes already in cart
  const existingItemIndex = cart.items.findIndex(
    (item) =>
      item.productId.toString() === productId &&
      areAttributesEqual(item.attributes as any, attributes)
  );

  if (existingItemIndex > -1) {
    // Update quantity
    cart.items[existingItemIndex].quantity += quantity;
    // Update price to current calculation (optional, usage decision)
    cart.items[existingItemIndex].priceAtTime = finalPrice;
  } else {
    // Add new item 
    cart.items.push({
      productId,
      quantity,
      priceAtTime: finalPrice,
      attributes: attributes || {},
    } as any);
  }

  await cart.save();

  // Return populated cart
  const populatedCart = await Cart.findById(cart._id)
    .populate('items.productId', 'title slug price discountPrice images stock');

  sendResponse(res, 200, populatedCart, 'Item added to cart');
});

/**
 * @desc    Update cart item quantity
 * @route   PUT /api/cart/update
 * @access  Private
 */
export const updateCartItem = asyncHandler(async (req: Request, res: Response) => {
  const { productId, quantity } = req.body;

  if (!productId || quantity === undefined) {
    throw new ApiError('Product ID and quantity are required', 400);
  }

  const cart = await Cart.findOne({ userId: req.user?.id });

  if (!cart) {
    throw new ApiError('Cart not found', 404);
  }

  const itemIndex = cart.items.findIndex(
    (item) => item.productId.toString() === productId
  );

  if (itemIndex === -1) {
    throw new ApiError('Item not in cart', 404);
  }

  if (quantity <= 0) {
    // Remove item if quantity is 0 or less
    cart.items.splice(itemIndex, 1);
  } else {
    // Check stock
    const product = await Product.findById(productId);
    if (product && product.stock < quantity) {
      throw new ApiError('Insufficient stock', 400);
    }
    cart.items[itemIndex].quantity = quantity;
  }

  await cart.save();

  const populatedCart = await Cart.findById(cart._id)
    .populate('items.productId', 'title slug price discountPrice images stock');

  sendResponse(res, 200, populatedCart, 'Cart updated');
});

/**
 * @desc    Remove item from cart
 * @route   DELETE /api/cart/remove/:productId
 * @access  Private
 */
export const removeFromCart = asyncHandler(async (req: Request, res: Response) => {
  const { productId } = req.params;

  const cart = await Cart.findOne({ userId: req.user?.id });

  if (!cart) {
    throw new ApiError('Cart not found', 404);
  }

  cart.items = cart.items.filter(
    (item) => item.productId.toString() !== productId
  );

  await cart.save();

  const populatedCart = await Cart.findById(cart._id)
    .populate('items.productId', 'title slug price discountPrice images stock');

  sendResponse(res, 200, populatedCart, 'Item removed from cart');
});

/**
 * @desc    Clear entire cart
 * @route   DELETE /api/cart/clear
 * @access  Private
 */
export const clearCart = asyncHandler(async (req: Request, res: Response) => {
  const cart = await Cart.findOne({ userId: req.user?.id });

  if (cart) {
    cart.items = [];
    await cart.save();
  }

  sendResponse(res, 200, null, 'Cart cleared');
});
