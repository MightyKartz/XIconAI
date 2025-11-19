'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Sparkles, Settings, Menu, X, Github, ExternalLink, Apple, Download } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'

export function NavigationHeader() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  const navigation = [
    { name: '首页', href: '/' },
    { name: '文档', href: '/docs' },
    { name: '配置', href: '/config' },
    { name: '生成', href: '/generate' }
  ]

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container mx-auto flex h-14 max-w-screen-2xl items-center justify-between px-4 sm:px-6 lg:px-8">
        {/* Logo - 优化尺寸 */}
        <div className="flex items-center space-x-2.5">
          <Link href="/" className="flex items-center space-x-2.5">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
              <Sparkles className="h-5 w-5" />
            </div>
            <div className="flex flex-col">
              <span className="text-lg font-bold text-foreground">
                XIconAI
              </span>
              <Badge variant="secondary" className="w-fit text-xs px-1.5 py-0">
                v2.0.1
              </Badge>
            </div>
          </Link>
        </div>

        {/* Desktop Navigation - 优化间距 */}
        <nav className="hidden md:flex items-center space-x-5">
          {navigation.map((item) => (
            <Link
              key={item.name}
              href={item.href}
              className="text-sm font-medium text-muted-foreground transition-colors hover:text-foreground"
            >
              {item.name}
            </Link>
          ))}
        </nav>

        {/* Actions - 优化间距 */}
        <div className="flex items-center space-x-2">
          <Link href="https://github.com/MightyKartz/icons" target="_blank" rel="noopener noreferrer">
            <Button variant="ghost" size="icon">
              <Github className="h-4 w-4" />
            </Button>
          </Link>

          <Button
            variant="default"
            size="sm"
            className="bg-black hover:bg-gray-800 text-white hidden sm:flex px-3"
            asChild
          >
            <a
              href="https://apps.apple.com/cn/app/xiconai-studio/id6754810915?mt=12"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center"
            >
              <Apple className="mr-1.5 h-3.5 w-3.5" />
              <span className="hidden lg:inline text-sm">App Store</span>
              <span className="lg:hidden text-sm">下载</span>
            </a>
          </Button>

          <Button variant="outline" size="sm" className="px-3" asChild>
            <Link href="/config">
              <Settings className="mr-1.5 h-3.5 w-3.5" />
              <span className="text-sm">配置</span>
            </Link>
          </Button>

          {/* Mobile Menu Button */}
          <Button
            variant="ghost"
            size="icon"
            className="md:hidden"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            {isMobileMenuOpen ? (
              <X className="h-4 w-4" />
            ) : (
              <Menu className="h-4 w-4" />
            )}
          </Button>
        </div>
      </div>

      {/* Mobile Menu - 优化间距 */}
      {isMobileMenuOpen && (
        <div className="border-t border-border/40 bg-background md:hidden">
          <nav className="container mx-auto px-4 py-3 sm:px-6 lg:px-8">
            <div className="space-y-2">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="block text-sm font-medium text-muted-foreground transition-colors hover:text-foreground py-1.5"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {item.name}
                </Link>
              ))}

              {/* App Store Download Link */}
              <a
                href="https://apps.apple.com/cn/app/xiconai-studio/id6754810915?mt=12"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center text-sm font-medium text-black hover:text-gray-700 py-1.5 transition-colors"
                onClick={() => setIsMobileMenuOpen(false)}
              >
                <Apple className="mr-1.5 h-3.5 w-3.5" />
                App Store 下载
                <ExternalLink className="ml-1 h-3 w-3" />
              </a>
            </div>
          </nav>
        </div>
      )}
    </header>
  )
}