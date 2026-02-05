import mongoose, { Document, Schema, Types } from 'mongoose';

/**
 * Notification Interface
 */
export interface INotification extends Document {
  userId: Types.ObjectId;
  title: string;
  message: string;
  type: 'order_status' | 'order_shipped' | 'order_delivered' | 'general';
  orderId?: Types.ObjectId;
  isRead: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const notificationSchema = new Schema<INotification>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['order_status', 'order_shipped', 'order_delivered', 'general'],
      default: 'general',
    },
    orderId: {
      type: Schema.Types.ObjectId,
      ref: 'Order',
    },
    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });

const Notification = mongoose.model<INotification>('Notification', notificationSchema);

export default Notification;
