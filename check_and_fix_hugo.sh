#!/usr/bin/env bash

TARGET_DIR="${1:-layouts}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

echo "🔍 Scanning and updating deprecated Hugo syntax in '$TARGET_DIR'..."

# 1. Update site and data references (.Site.Data -> hugo.Data, .Site.Author -> site.Author)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Site\.Data/hugo\.Data/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Site\.Author/site\.Author/g' {} +

# 2. Update page collection references (.Data.Pages -> .RegularPages)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Data\.Pages/\.RegularPages/g' {} +

# 3. Update Language & Locale references (.Site.Language.Locale -> site.Language.Locale)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Site\.Language\.Locale/site\.Language\.Locale/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Site\.LanguageCode/site\.LanguageCode/g' {} +

# 4. Update math functions to math.* namespace
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/(\s*add/(math.Add/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/(\s*mul/(math.Mul/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/(\s*sub/(math.Sub/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/(\s*div/(math.Div/g' {} +

find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/ add / math.Add /g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/ mul / math.Mul /g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/ sub / math.Sub /g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/ div / math.Div /g' {} +

# 5. Update URL & Permalink properties (.Site.URL / .URL -> .Site.BaseURL / .RelPermalink)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Site\.URL/\.Site\.BaseURL/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/\.Page\.URL/\.Page\.RelPermalink/g' {} +

# 6. Update URL pipeline transformations (absURL -> relURL)
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/|\s*absURL/| relURL/g' {} +
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/absURL/relURL/g' {} +

# 7. Clean deprecated HTML4 iframe attributes (frameborder="0")
find "$TARGET_DIR" -type f \( -name "*.html" -o -name "*.xml" \) -exec sed -i '' 's/frameborder="0"/style="border:0;"/g' {} +

echo "✅ Automatic updates applied in '$TARGET_DIR'."