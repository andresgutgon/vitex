import { Plugin } from 'vite'

export interface InertiaPhoenixPluginOptions {
  /**
   * Path to your SSR entry file
   * Example: './resources/js/ssr.tsx'
   */
  entrypoint: string
}

/**
 * Inertia Phoenix Vite Plugin
 * Provides SSR support for Inertia.js + Phoenix during development
 */
export default function inertiaPhoenixPlugin(options: InertiaPhoenixPluginOptions): Plugin
