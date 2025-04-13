import { Plugin } from 'vite'

export interface VitexPluginOptions {
  /**
   * Path to your SSR entry file
   * Example: './js/ssr.tsx'
   */
  inertiaSSREntrypoint: string
}

/**
 * Vitex Plugin
 * Provides SSR support for Inertia.js + Phoenix during development
 */
export default function vitexPlugin(options: VitexPluginOptions): Plugin
