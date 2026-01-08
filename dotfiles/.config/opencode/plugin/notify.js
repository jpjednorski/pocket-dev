/**
 * OpenCode notification plugin for pocket-dev
 * Sends push notifications via ntfy.sh when OpenCode needs input
 */
export const NotifyPlugin = async ({ $, directory }) => {
  const topic = process.env.NTFY_TOPIC
  if (!topic) return {}

  const project = directory ? directory.split('/').pop() : 'opencode'

  const sendNotification = async (message, priority = 'high') => {
    try {
      await $`curl -sf -X POST https://ntfy.sh/${topic} \
        -H "Title: pocket-dev" \
        -H "Priority: ${priority}" \
        -H "Tags: robot" \
        -d ${message}`.quiet()
    } catch {
    }
  }

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case 'session.idle':
          await sendNotification(`${project}: OpenCode needs input`)
          break
        case 'session.error':
          await sendNotification(`${project}: OpenCode error`, 'urgent')
          break
      }
    }
  }
}
