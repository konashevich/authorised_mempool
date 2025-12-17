#!/bin/bash

# Configuration
INPUT_FILE="sanctioned_validators_paper.md"
METADATA_FILE="paper_metadata.yaml"
OUTPUT_FILE="sanctioned_validators_paper.pdf"
TEMPLATE_FILE="lncs_template.tex"
TEMP_BODY="temp_body.md"
CLS_URL="https://raw.githubusercontent.com/prosysscience/llncs/master/llncs.cls"
BST_URL="https://raw.githubusercontent.com/prosysscience/llncs/master/splncs04.bst"

# 1. Check Dependencies
echo "Checking dependencies..."
if ! command -v pandoc &> /dev/null; then
    echo "Error: pandoc is not installed."
    echo "Please install it: sudo apt install pandoc"
    exit 1
fi

if ! command -v pdflatex &> /dev/null; then
    echo "Error: pdflatex (texlive) is not installed."
    echo "Please install it: sudo apt install texlive-latex-base texlive-latex-extra"
    exit 1
fi

# 1b. Generate Metadata if missing
# 1b. Generate Metadata dynamically from source
echo "Extracting metadata from $INPUT_FILE..."
# Extract Abstract (Line 6)
ABSTRACT=$(sed -n '6s/^\*\*Abstract.\*\* //p' "$INPUT_FILE")
# Extract Keywords (Line 8)
KEYWORDS=$(sed -n '8s/^\*\*Keywords:\*\* //p' "$INPUT_FILE")

echo "Generating metadata file..."
cat > "$METADATA_FILE" << EOF
---
title: "Addressing Sanctioned and Unethical Validators in Public Blockchain Applications"
author: "Oleksii Konashevych, PhD"
institute: "oleksii@konashevych.com"
keywords: "$KEYWORDS"
abstract: |
  $ABSTRACT
...
EOF

# 2. Download LNCS Class and Bib Style if missing
if [ ! -f "llncs.cls" ]; then
    echo "Downloading llncs.cls..."
    wget -q -O llncs.cls "$CLS_URL"
    if [ $? -ne 0 ]; then
        echo "Failed to download llncs.cls"
        exit 1
    fi
fi

if [ ! -f "splncs04.bst" ]; then
    echo "Downloading splncs04.bst..."
    wget -q -O splncs04.bst "$BST_URL"
    if [ $? -ne 0 ]; then
        echo "Failed to download splncs04.bst. Continuing without it (citations might look wrong)."
    fi
fi

# 3. Create Custom LNCS Pandoc Template
echo "Creating LNCS template..."
cat > "$TEMPLATE_FILE" << 'EOF'
\documentclass{llncs}
\usepackage[utf8]{inputenc}
\usepackage{xurl}
\usepackage{graphicx}
\usepackage{listings}
\usepackage{xcolor}
\usepackage[hidelinks,breaklinks]{hyperref}

% Code block styling
\lstset{
  basicstyle=\ttfamily\scriptsize,
  breaklines=true,
  frame=single,
  backgroundcolor=\color{gray!10},
  columns=flexible
}

% Define passthrough for pandoc listings
\newcommand{\passthrough}[1]{#1}

% Fix for pandoc tightlist
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}

$if(title)$
\title{$title$}
$endif$
$if(author)$
\author{$author$}
$endif$
$if(institute)$
\institute{$institute$}
$endif$

\begin{document}

$if(title)$
\maketitle
$endif$

$if(abstract)$
\begin{abstract}
$abstract$
\keywords{$keywords$}
\end{abstract}
$endif$

$body$

\bibliographystyle{splncs04}
$if(bibliography)$
\bibliography{$bibliography$}
$endif$

\end{document}
EOF

# 4. Prepare Markdown Content
# Strip the first 11 lines (custom header) to get the body
echo "Preparing document body..."
tail -n +12 "$INPUT_FILE" > "$TEMP_BODY"

# Clean up headers to avoid double numbering and 0.x sectioning
# 1. Remove hardcoded numbers (e.g., "1 Introduction" -> "Introduction")
sed -i -E 's/^(#+) [0-9.]+[[:space:]]+/\1 /' "$TEMP_BODY"
# 2. Make subsections "References" and "Annex" unnumbered
sed -i 's/^## References/## References {-}/' "$TEMP_BODY"
sed -i 's/^## Annex/## Annex {-}/' "$TEMP_BODY"

# 5. Run Pandoc
echo "Generating PDF..."
pandoc "$TEMP_BODY" \
    --from markdown \
    --template="$TEMPLATE_FILE" \
    --metadata-file="$METADATA_FILE" \
    --pdf-engine=pdflatex \
    --listings \
    --shift-heading-level-by=-1 \
    -o "$OUTPUT_FILE"

EXIT_CODE=$?

# 6. Cleanup
rm "$TEMP_BODY" "$TEMPLATE_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "Success! PDF generated at: $OUTPUT_FILE"
else
    echo "Error generating PDF. Please check pandoc output."
fi
