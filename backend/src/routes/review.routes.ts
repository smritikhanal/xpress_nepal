import { Router } from 'express';
import { getProductReviews, createReview, deleteReview, getMyReviews } from '../controllers/review.controller.js';
import { protect } from '../middleware/auth.middleware.js';
import { validate } from '../middleware/validate.middleware.js';
import {
  createReviewSchema,
  getProductReviewsSchema,
  deleteReviewSchema,
} from '../validators/review.validators.js';

const router = Router();

router.get('/my-reviews', protect, getMyReviews);
router.get('/', validate(getProductReviewsSchema), getProductReviews);
router.post('/', protect, validate(createReviewSchema), createReview);
router.delete('/:id', protect, validate(deleteReviewSchema), deleteReview);

export default router;
