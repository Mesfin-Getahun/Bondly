import { auth } from '../config';

/**
 * Placeholder helper to verify Firebase Auth token and ensure caller is authorized
 */
export async function verifyAuthToken(bearerToken?: string): Promise<string | null> {
  if (!bearerToken || !bearerToken.startsWith('Bearer ')) {
    return null;
  }
  const token = bearerToken.split('Bearer ')[1];
  try {
    const decoded = await auth.verifyIdToken(token);
    return decoded.uid;
  } catch {
    return null;
  }
}
