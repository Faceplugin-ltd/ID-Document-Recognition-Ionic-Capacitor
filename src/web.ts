import { WebPlugin } from '@capacitor/core';
import type { DocumentReaderSdkPlugin } from './definitions';

export class DocumentReaderSdkWeb
  extends WebPlugin
  implements DocumentReaderSdkPlugin
{
  private unsupported(): never {
    throw this.unimplemented(
      'DocumentReaderSdk requires a native Android or iOS build (Capacitor).'
    );
  }

  async getMachineCode(): Promise<{ value: string }> {
    this.unsupported();
  }

  async setActivation(_options: {
    license: string;
  }): Promise<{ value: number }> {
    this.unsupported();
  }

  async init(): Promise<{ value: number }> {
    this.unsupported();
  }

  async deinit(): Promise<void> {
    this.unsupported();
  }

  async startNewSession(_options?: {
    optionsJson?: string;
  }): Promise<{ value: string }> {
    this.unsupported();
  }

  async locateDocument(_options: {
    image: string;
  }): Promise<{ value: string }> {
    this.unsupported();
  }

  async recognize(_options: {
    front: string;
    back?: string | null;
    authenticity?: boolean;
    authenticityMode?: string;
  }): Promise<{ value: string }> {
    this.unsupported();
  }

  async documentRecognition(_options: {
    front: string;
    back?: string | null;
  }): Promise<{ value: string }> {
    this.unsupported();
  }

  async documentLiveness(_options: {
    front: string;
    back?: string | null;
  }): Promise<{ value: string }> {
    this.unsupported();
  }

  async lastLicenseError(): Promise<{ value: string }> {
    this.unsupported();
  }

  async getLicenseStatus(): Promise<{ value: string }> {
    this.unsupported();
  }

  async writeStatus(_options: { payload: string }): Promise<void> {
    this.unsupported();
  }

  async startLivePreview(_options?: { frontCamera?: boolean }): Promise<void> {
    this.unsupported();
  }

  async stopLivePreview(): Promise<void> {
    this.unsupported();
  }

  async takeLiveSnapshot(): Promise<{ uri: string; path: string }> {
    this.unsupported();
  }
}
