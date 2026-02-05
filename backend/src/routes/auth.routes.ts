import { Router } from 'express';
import { register, login, getMe, updateProfile } from '../controllers/auth.controller.js';
import { becomeSeller } from '../controllers/seller.controller.js';
import { protect, requireCustomer } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import { registerSchema, loginSchema } from '../validators/auth.validators.js';
import { upload } from '../middleware/upload.middleware.js';

const router = Router();

/**
 * Auth Routes
 * 
 * POST /api/auth/register      - Create new user account
 * POST /api/auth/login         - Authenticate and get token
 * GET  /api/auth/me            - Get current user (protected)
 * POST /api/auth/become-seller - Upgrade customer to seller (protected)
 */

// router.post('/register', validate(registerSchema), register);
// router.post('/login', validate(loginSchema), login);
router.get('/me', protect, getMe);
router.put('/me', protect, updateProfile);
router.post('/become-seller', protect, requireCustomer, becomeSeller);

router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);
router.put('/:id', protect, upload.single('image'), updateProfile);

export default router;
