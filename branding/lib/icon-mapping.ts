/**
 * Lucide to Iconsax icon mapping
 * Maps lucide-svelte icon names to iconsax-svelte icon names
 * If an icon doesn't exist in iconsax, it will fallback to fontawesome
 */

export const lucideToIconsax: Record<string, string> = {
  // Arrows
  'ArrowRight': 'ArrowRight',
  'ArrowLeft': 'ArrowLeft',
  'ArrowRightLeft': 'ArrowSwapHorizontal',
  'ChevronRight': 'ArrowRight1',
  'ChevronLeft': 'ArrowLeft1',
  'ChevronDown': 'ArrowDown1',
  'ChevronUp': 'ArrowUp1',
  
  // Media
  'PlayCircle': 'PlayCircle',
  'Download': 'Download',
  
  // UI Elements
  'Menu': 'Menu',
  'X': 'CloseCircle',
  'Sun': 'Sun1',
  'Moon': 'Moon',
  'Plus': 'Add',
  'Search': 'SearchNormal',
  'Filter': 'Filter',
  
  // Status
  'CheckCircle2': 'TickCircle',
  'CheckSquare': 'TickSquare',
  'Clock': 'Clock',
  'Calendar': 'Calendar',
  
  // Communication
  'MessageSquare': 'Message',
  'MessagesSquare': 'Messages2',
  'Mail': 'Sms',
  
  // Tech
  'Cpu': 'Cpu',
  'Monitor': 'Monitor',
  'Smartphone': 'Mobile',
  'Code': 'Code',
  'Settings': 'Setting',
  'Folder': 'Folder',
  'FileText': 'DocumentText',
  'Wifi': 'Wifi',
  'Github': 'Github', // May not exist, will check
  
  // Users & Social
  'User': 'User',
  'Users': 'People',
  'Crown': 'Crown',
  'HelpCircle': 'QuestionCircle',
  
  // Security & Privacy
  'Shield': 'Security',
  'Lock': 'Lock',
  'Key': 'Key',
  'CloudOff': 'CloudSlash',
  'Globe': 'Global',
  
  // Content
  'Book': 'Book',
  'Video': 'Video',
  'Sparkles': 'MagicStar', // May not exist
  
  // Other
  'Zap': 'Flash', // Lightning/Flash icon
};

/**
 * Icons that don't exist in iconsax and should use fontawesome
 */
export const fontawesomeOnly: string[] = [
  // Add icons that don't exist in iconsax here
  // Example: 'SomeIcon'
];

/**
 * Check if an icon exists in iconsax
 */
export function hasIconsaxIcon(lucideName: string): boolean {
  return lucideName in lucideToIconsax && !fontawesomeOnly.includes(lucideName);
}

/**
 * Get iconsax icon name from lucide icon name
 */
export function getIconsaxName(lucideName: string): string | null {
  return lucideToIconsax[lucideName] || null;
}

