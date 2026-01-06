#!/usr/bin/env python3
"""
Convert WebP images to PNG format
"""
import os
from pathlib import Path
from PIL import Image

def convert_webp_to_png(input_dir, output_dir=None):
    """
    Convert all WebP files in input_dir to PNG format
    If output_dir is None, saves to the same directory
    """
    input_path = Path(input_dir)
    
    if output_dir is None:
        output_path = input_path
    else:
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
    
    # Find all WebP files
    webp_files = list(input_path.glob("*.webp"))
    
    if not webp_files:
        print(f"No WebP files found in {input_dir}")
        return
    
    print(f"Found {len(webp_files)} WebP files")
    
    converted = 0
    for webp_file in webp_files:
        try:
            # Open WebP image
            img = Image.open(webp_file)
            
            # Convert to RGB if necessary (for PNG compatibility)
            if img.mode in ('RGBA', 'LA', 'P'):
                # Keep transparency
                pass
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Create output filename
            png_filename = webp_file.stem + '.png'
            png_path = output_path / png_filename
            
            # Save as PNG
            img.save(png_path, 'PNG', optimize=True)
            print(f"✓ Converted: {webp_file.name} → {png_filename}")
            converted += 1
            
        except Exception as e:
            print(f"✗ Error converting {webp_file.name}: {e}")
    
    print(f"\nConversion complete! {converted}/{len(webp_files)} files converted.")

if __name__ == "__main__":
    # Set paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    mobile_dir = project_root / "assets" / "mobile"
    
    # Convert WebP to PNG in the same directory
    convert_webp_to_png(mobile_dir)





