# Authorised Mempool & Sanctioned Validators

This repository contains the research and implementation for the paper **"Addressing Sanctioned and Unethical Validators in Public Blockchain Applications"**.

The project proposes a Dual-Layer Enforcement Mechanism to allow government-regulated applications to run on public permissionless blockchains (like Ethereum) while strictly preventing sanctioned or unethical validators from processing their transactions/earning fees.

## Repository Structure

*   **`sanctioned_validators_paper.md`**: The academic paper written in Lecture Notes in Computer Science (LNCS) style.
*   **`contracts/`**: Solidity smart contract implementation of the "IT Artifact".
    *   `ValidatorRegistry.sol`: Manages the whitelist of compliant validators ("Regulated Perimeter").
    *   `SanctionGuard.sol`: Logic to check `block.coinbase` against the registry.
    *   `RegulatedToken.sol`: Example ERC-20 token implementing the guard.
*   **`make_pdf.sh`**: A shell script to generate a formatted PDF of the paper.

## Generating the Paper

To generate the LNCS-style PDF from the markdown source:

1.  **Install Dependencies** (Ubuntu/Debian):
    ```bash
    sudo apt install pandoc texlive-latex-base texlive-latex-extra
    ```

2.  **Run Build Script**:
    ```bash
    chmod +x make_pdf.sh
    ./make_pdf.sh
    ```

This will produce `sanctioned_validators_paper.pdf`.

## License
MIT
