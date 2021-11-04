import { AppConfig } from '../models/app-config';

declare global {
    interface Window {
        env: AppConfig;
    }
}

window.env = window.env || {};
