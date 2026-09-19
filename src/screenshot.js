// html2canvas-pro, not html2canvas: Tailwind v4 emits every colour as oklch(),
// which html2canvas 1.4.1 cannot parse — it threw "unsupported color function
// oklch" and no PNG was ever produced.
import html2canvas from 'html2canvas-pro'

// Capture an element as a PNG download.
//
// Shared by ResultsTable and StandingsView: both had their own near-identical
// copy of this, so every fix here had to be made twice.
export async function captureElement(elementId, filenamePrefix) {
  const element = document.getElementById(elementId)
  if (!element) {
    console.error(`[CSRO] Cannot screenshot: #${elementId} not found`)
    return
  }

  // Wide tables (qualifying carries an extra Gap column) scroll inside an
  // overflow-x-auto wrapper and are capped at 900px, so html2canvas was
  // capturing a clipped table. Let the content set its own width for the shot.
  const scrollers = Array.from(element.querySelectorAll('.overflow-x-auto'))
  const previous = {
    maxWidth: element.style.maxWidth,
    width: element.style.width,
    overflows: scrollers.map((s) => s.style.overflow)
  }

  try {
    // Only unclamp when something is genuinely cut off, otherwise the capture
    // stretches tables that already fit and the columns drift apart.
    const isClipped = scrollers.some((s) => s.scrollWidth > s.clientWidth)
    scrollers.forEach((s) => {
      s.style.overflow = 'visible'
    })
    if (isClipped) {
      element.style.maxWidth = 'none'
      element.style.width = 'max-content'
    }

    const isDarkMode = document.documentElement.classList.contains('dark')
    const canvas = await html2canvas(element, {
      backgroundColor: isDarkMode ? '#111827' : '#ffffff',
      scale: 2,
      logging: false,
      useCORS: true
    })

    const blob = await new Promise((resolve) => canvas.toBlob(resolve))
    if (!blob) throw new Error('canvas.toBlob() returned no data')

    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.download = `${filenamePrefix}-${new Date().toISOString().split('T')[0]}.png`
    link.href = url
    link.click()
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Error capturing screenshot:', error)
    throw error
  } finally {
    // Always restore, so a failed capture can't leave the page stretched out.
    element.style.maxWidth = previous.maxWidth
    element.style.width = previous.width
    scrollers.forEach((s, i) => {
      s.style.overflow = previous.overflows[i]
    })
  }
}
