
from PIL import Image
import sys

def get_dominant_colors(image_path, num_colors=5):
    try:
        image = Image.open(image_path)
        image = image.resize((150, 150))
        # Convert to RGB to ensure we get tuple (r,g,b)
        image = image.convert('RGB')
        # Quantize to num_colors
        result = image.quantize(colors=num_colors)
        # Get palette
        palette = result.getpalette() # [r, g, b, r, g, b, ...]
        # Get colors count
        colors = result.getcolors(150*150)
        
        print(f"Found {len(colors)} colors:")
        sorted_colors = sorted(colors, key=lambda x: x[0], reverse=True)
        
        for count, index in sorted_colors:
            # palette is a flat list
            r = palette[index*3]
            g = palette[index*3+1]
            b = palette[index*3+2]
            print(f"Color: #{r:02x}{g:02x}{b:02x}, Count: {count}")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        get_dominant_colors(sys.argv[1])
    else:
        print("Usage: python analyze_colors.py <image_path>")
