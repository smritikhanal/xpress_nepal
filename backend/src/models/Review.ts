import mongoose, { Document, Schema, Types } from 'mongoose';

/**
 * Review Interface
 * Product reviews and ratings by users
 */
export interface IReview extends Document {
  userId: Types.ObjectId;
  productId: Types.ObjectId;
  rating: number;
  comment: string;
  createdAt: Date;
  updatedAt: Date;
}

const reviewSchema = new Schema<IReview>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'User ID is required'],
    },
    productId: {
      type: Schema.Types.ObjectId,
      ref: 'Product',
      required: [true, 'Product ID is required'],
    },
    rating: {
      type: Number,
      required: [true, 'Rating is required'],
      min: [1, 'Rating must be at least 1'],
      max: [5, 'Rating cannot exceed 5'],
    },
    comment: {
      type: String,
      required: [true, 'Comment is required'],
      trim: true,
      maxlength: [1000, 'Comment cannot exceed 1000 characters'],
    },
  },
  {
    timestamps: true,
  }
);

// Prevent duplicate reviews from same user for same product
reviewSchema.index({ userId: 1, productId: 1 }, { unique: true });
// Index for product reviews lookup
reviewSchema.index({ productId: 1 });

const Review = mongoose.model<IReview>('Review', reviewSchema);

export default Review;
