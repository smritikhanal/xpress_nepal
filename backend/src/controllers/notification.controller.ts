import { Request, Response } from 'express';
import Notification from '../models/Notification.js';
import { asyncHandler, sendResponse, ApiError } from '../utils/apiHelpers.js';

/**
 * @desc    Get user's notifications
 * @route   GET /api/notifications
 * @access  Private
 */
export const getNotifications = asyncHandler(async (req: Request, res: Response) => {
  const { unreadOnly } = req.query;
  
  const filter: any = { userId: req.user?.id };
  
  if (unreadOnly === 'true') {
    filter.isRead = false;
  }

  const notifications = await Notification.find(filter)
    .sort({ createdAt: -1 })
    .limit(50);

  const unreadCount = await Notification.countDocuments({
    userId: req.user?.id,
    isRead: false,
  });

  sendResponse(res, 200, { notifications, unreadCount });
});

/**
 * @desc    Mark notification as read
 * @route   PUT /api/notifications/:id/read
 * @access  Private
 */
export const markAsRead = asyncHandler(async (req: Request, res: Response) => {
  const notification = await Notification.findOne({
    _id: req.params.id,
    userId: req.user?.id,
  });

  if (!notification) {
    throw new ApiError('Notification not found', 404);
  }

  notification.isRead = true;
  await notification.save();

  sendResponse(res, 200, notification);
});

/**
 * @desc    Mark all notifications as read
 * @route   PUT /api/notifications/read-all
 * @access  Private
 */
export const markAllAsRead = asyncHandler(async (req: Request, res: Response) => {
  await Notification.updateMany(
    { userId: req.user?.id, isRead: false },
    { isRead: true }
  );

  sendResponse(res, 200, { message: 'All notifications marked as read' });
});

/**
 * @desc    Delete notification
 * @route   DELETE /api/notifications/:id
 * @access  Private
 */
export const deleteNotification = asyncHandler(async (req: Request, res: Response) => {
  const notification = await Notification.findOneAndDelete({
    _id: req.params.id,
    userId: req.user?.id,
  });

  if (!notification) {
    throw new ApiError('Notification not found', 404);
  }

  sendResponse(res, 200, { message: 'Notification deleted' });
});

/**
 * Helper function to create notification (used by other controllers)
 */
export const createNotification = async (
  userId: string,
  title: string,
  message: string,
  type: 'order_status' | 'order_shipped' | 'order_delivered' | 'general',
  orderId?: string
) => {
  await Notification.create({
    userId,
    title,
    message,
    type,
    orderId,
  });
};
