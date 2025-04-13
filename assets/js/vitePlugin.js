const jsonResponse = (
  res,
  statusCode,
  data,
) => {
  res.statusCode = statusCode
  res.setHeader('Content-Type', 'application/json')
  res.end(JSON.stringify(data))
}

const jsonMiddleware = (req, res, next) => {
  let data = ''
  req.on('data', (chunk) => (data += chunk))
  req.on('end', () => {
    try {
      req.body = JSON.parse(data)
      next()
    } catch {
      jsonResponse(res, 400, { error: 'Invalid JSON' })
    }
  })
  req.on('error', () => {
    jsonResponse(res, 500, { error: 'Internal Server Error' })
  })
}

/**
 * Use this plugin if you use SSR in InertiaJS and want HMR working
 * on the server JS code of your app
 *
 * @param {Object} options
 * @param {string} options.entrypoint - Path to your SSR entry file (Ex.: "./js/ssr.tsx")
 */
export default function inertiaPhoenixPlugin({ entrypoint }) {
  return {
    name: 'inertia-phoenix',
    configureServer(server) {
      if (!entrypoint) {
        throw new Error(
          `[inertia-phoenix] Missing required \`entrypoint\` in plugin options.

Please pass the path to your SSR entry file.

Example:
  import inertiaPhoenixPlugin from '@inertia-phoenix/vitePlugin'
  inertiaPhoenixPlugin({ entrypoint: './js/ssr.{jsx|tsx}' })`
        )
      }

      // exit cleanly with Phoenix (dev only)
      process.stdin.on('close', () => process.exit(0))
      process.stdin.resume()

      server.middlewares.use((req, res, next) => {
        const path = req.url?.split('?', 1)[0]
        const isInertiaRequest = req.method === 'POST' && path === '/ssr_render'
        if (!isInertiaRequest) return next()

        jsonMiddleware(req, res, async () => {
          try {
            const { render } = await server.ssrLoadModule(entrypoint)
            const page = (await render(req.body))
            jsonResponse(res, 200, page)
          } catch (e) {
            if (e instanceof Error) {
              server.ssrFixStacktrace(e)

              jsonResponse(res, 500, {
                error: {
                  message: e.message,
                  stack: e.stack,
                },
              })
            } else {
              jsonResponse(res, 500, {
                error: {
                  message: 'Unknown error',
                  detail: e,
                },
              })
            }
          }
        })
      })
    },
  }
}
