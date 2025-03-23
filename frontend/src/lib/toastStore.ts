import { writable } from 'svelte/store';

// Define toast interface
interface Toast {
  id: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  duration: number;
  position: string;
}

// Create a writable store with an empty array of toasts
const toasts = writable<Toast[]>([]);

// Helper function to generate unique ID
const generateId = (): string => `toast_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

// Function to add a toast to the store
export function addToast(
  message: string, 
  type: 'info' | 'success' | 'warning' | 'error' = 'info', 
  duration = 3000, 
  position = 'top-end'
): string {
  const id = generateId();
  
  // Add new toast to the store
  toasts.update(all => [
    ...all,
    { id, message, type, duration, position }
  ]);
  
  // If duration is provided, auto-remove after specified time
  if (duration > 0) {
    setTimeout(() => {
      removeToast(id);
    }, duration);
  }
  
  return id;
}

// Function to remove a toast from the store
export function removeToast(id: string): void {
  toasts.update(all => all.filter(toast => toast.id !== id));
}

// Toast type convenience functions
export const showInfo = (message: string, duration?: number) => addToast(message, 'info', duration);
export const showSuccess = (message: string, duration?: number) => addToast(message, 'success', duration);
export const showWarning = (message: string, duration?: number) => addToast(message, 'warning', duration);
export const showError = (message: string, duration?: number) => addToast(message, 'error', duration);

export default toasts; 