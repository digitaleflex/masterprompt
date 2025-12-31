import './globals.css'

export const metadata = {
  title: 'Next.js avec sécurité intégrée',
  description: 'Application Next.js avec DevSecOps intégré',
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}