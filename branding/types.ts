export interface NavItem {
  label: string;
  href: string;
}

export interface Feature {
  title: string;
  description: string;
  icon: string; // Icon name or component identifier
  imagePosition: 'left' | 'right';
  benefits?: string[];
  visualType?: 'desktop' | 'mobile';
}

export interface Testimonial {
  quote: string;
  author: string;
  role: string;
  company: string;
  avatar: string;
}