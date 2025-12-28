/**
 * 이미지 지연 로딩 유틸리티
 * Intersection Observer를 사용하여 뷰포트에 가까워질 때만 이미지를 로드합니다.
 */

export interface ImageLoaderOptions {
  rootMargin?: string;
  threshold?: number;
  enablePlaceholder?: boolean;
}

export class ImageLoader {
  private observer: IntersectionObserver | null = null;
  private imageElements: Map<HTMLImageElement, () => void> = new Map();

  constructor(options: ImageLoaderOptions = {}) {
    const { rootMargin = '50px', threshold = 0.01 } = options;

    if (typeof IntersectionObserver !== 'undefined') {
      this.observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              const img = entry.target as HTMLImageElement;
              const loadHandler = this.imageElements.get(img);
              if (loadHandler) {
                loadHandler();
                this.observer?.unobserve(img);
                this.imageElements.delete(img);
              }
            }
          });
        },
        {
          rootMargin,
          threshold,
        }
      );
    }
  }

  /**
   * 이미지 요소에 지연 로딩을 적용합니다.
   * @param img 이미지 요소
   * @param src 실제 이미지 소스
   * @param placeholder 플레이스홀더 이미지 (선택사항)
   */
  observe(img: HTMLImageElement, src: string, placeholder?: string): void {
    if (!this.observer) {
      // Intersection Observer를 지원하지 않는 경우 즉시 로드
      img.src = src;
      return;
    }

    // 플레이스홀더 설정
    if (placeholder) {
      img.src = placeholder;
    } else {
      // 투명한 1x1 픽셀 이미지로 플레이스홀더 생성
      img.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="1" height="1"%3E%3C/svg%3E';
    }

    // 로딩 핸들러 설정
    const loadHandler = () => {
      // 이미지가 이미 로드되었는지 확인
      if (img.src !== src) {
        img.src = src;
      }
    };

    this.imageElements.set(img, loadHandler);
    this.observer.observe(img);
  }

  /**
   * 이미지 요소 관찰을 중지합니다.
   */
  unobserve(img: HTMLImageElement): void {
    this.observer?.unobserve(img);
    this.imageElements.delete(img);
  }

  /**
   * 모든 관찰을 중지하고 리소스를 정리합니다.
   */
  disconnect(): void {
    this.observer?.disconnect();
    this.imageElements.clear();
  }
}

// 싱글톤 인스턴스
let imageLoaderInstance: ImageLoader | null = null;

/**
 * 이미지 로더 인스턴스를 가져옵니다.
 */
export function getImageLoader(options?: ImageLoaderOptions): ImageLoader {
  if (!imageLoaderInstance) {
    imageLoaderInstance = new ImageLoader(options);
  }
  return imageLoaderInstance;
}















