import { registerPlugin } from '@capacitor/core';
import type { DocumentReaderSdkPlugin } from './definitions';
import { authenticityModeValue, type AuthenticityArg } from './authenticityMode';
import {
  parseLicenseStatus,
  type LicenseStatus,
} from './licenseStatus';
import { normalizeResultJson } from './normalizeResult';

export const DocumentReaderSdkNative = registerPlugin<DocumentReaderSdkPlugin>(
  'DocumentReaderSdk',
  {
    web: () => import('./web').then((m) => new m.DocumentReaderSdkWeb()),
  }
);

export type ImageInput = string;
export type LiveCameraPhoto = { uri: string; path: string };
export type { AuthenticityArg, AuthenticityMode } from './authenticityMode';

export async function getMachineCode(): Promise<string> {
  const { value } = await DocumentReaderSdkNative.getMachineCode();
  return value;
}

export async function setActivation(license: string): Promise<number> {
  const { value } = await DocumentReaderSdkNative.setActivation({ license });
  return value;
}

export async function init(): Promise<number> {
  const { value } = await DocumentReaderSdkNative.init();
  return value;
}

export async function deinit(): Promise<void> {
  await DocumentReaderSdkNative.deinit();
}

export async function startNewSession(
  optionsJson: string = '{"scenario":"FullProcess","series":false}'
): Promise<string> {
  const { value } = await DocumentReaderSdkNative.startNewSession({
    optionsJson,
  });
  return value;
}

export async function locateDocument(image: ImageInput): Promise<string> {
  const { value } = await DocumentReaderSdkNative.locateDocument({ image });
  return value;
}

export async function recognize(
  front: ImageInput,
  back?: ImageInput | null,
  authenticity: AuthenticityArg = true
): Promise<string> {
  const { value } = await DocumentReaderSdkNative.recognize({
    front,
    back: back ?? null,
    authenticityMode: authenticityModeValue(authenticity),
  });
  return normalizeResultJson(typeof value === 'string' ? value : '');
}

export async function documentRecognition(
  front: ImageInput,
  back?: ImageInput | null
): Promise<string> {
  const { value } = await DocumentReaderSdkNative.documentRecognition({
    front,
    back: back ?? null,
  });
  return normalizeResultJson(typeof value === 'string' ? value : '');
}

export async function documentLiveness(
  front: ImageInput,
  back?: ImageInput | null
): Promise<string> {
  const { value } = await DocumentReaderSdkNative.documentLiveness({
    front,
    back: back ?? null,
  });
  return normalizeResultJson(typeof value === 'string' ? value : '');
}

export async function lastLicenseError(): Promise<string> {
  const { value } = await DocumentReaderSdkNative.lastLicenseError();
  return value;
}

/** Parsed license capabilities (`label` is what About / home status show). */
export async function getLicenseStatus(): Promise<LicenseStatus> {
  const { value } = await DocumentReaderSdkNative.getLicenseStatus();
  return parseLicenseStatus(value);
}

export async function writeStatus(
  payload: Record<string, unknown>
): Promise<void> {
  await DocumentReaderSdkNative.writeStatus({
    payload: JSON.stringify(payload),
  });
}

export async function startLivePreview(
  frontCamera: boolean = false
): Promise<void> {
  await DocumentReaderSdkNative.startLivePreview({ frontCamera });
}

export async function stopLivePreview(): Promise<void> {
  await DocumentReaderSdkNative.stopLivePreview();
}

export async function takeLiveSnapshot(): Promise<LiveCameraPhoto> {
  const snap = await DocumentReaderSdkNative.takeLiveSnapshot();
  return { uri: snap.uri, path: snap.path };
}
