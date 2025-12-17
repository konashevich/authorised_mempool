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
if [ ! -f "$METADATA_FILE" ]; then
    echo "Generating metadata file..."
    cat > "$METADATA_FILE" << 'EOF'
---
title: "Addressing Sanctioned and Unethical Validators in Public Blockchain Applications"
author: "Oleksii Konashevych, PhD"
institute: "oleksii@konashevych.com"
keywords: "Public Blockchain, Sanctioned Validators, Smart Contracts, Government Applications, Design Science Research"
abstract: |
  Governments exploring public blockchain infrastructure face a critical challenge: ensuring that transaction processing does not inadvertently reward sanctioned or unethical validators. This paper proposes a dual-layer enforcement mechanism designed to reconcile the openness of permissionless networks with strict regulatory compliance. Employing Design Science Research (DSR) methodology, we introduce an "IT artifact" comprising (1) an infrastructure-level authorised transaction submission channel and (2) an application-level smart contract whitelist. This architecture ensures that sanctioned entities are technically and economically excluded from participating in government-regulated applications, demonstrating that control over applications does not require control over the underlying infrastructure.
...
EOF
fi

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
\usepackage{url}
\usepackage{graphicx}
\usepackage{listings}
\usepackage{xcolor}
\usepackage{hyperref}

% Code block styling
\lstset{
  basicstyle=\ttfamily\small,
  breaklines=true,
  frame=single,
  backgroundcolor=\color{gray!10},
  columns=flexible
}

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

# 5. Run Pandoc
echo "Generating PDF..."
pandoc "$TEMP_BODY" \
    --from markdown \
    --template="$TEMPLATE_FILE" \
    --metadata-file="$METADATA_FILE" \
    --pdf-engine=pdflatex \
    -o "$OUTPUT_FILE"

EXIT_CODE=$?

# 6. Cleanup
rm "$TEMP_BODY" "$TEMPLATE_FILE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "Success! PDF generated at: $OUTPUT_FILE"
else
    echo "Error generating PDF. Please check pandoc output."
fi
