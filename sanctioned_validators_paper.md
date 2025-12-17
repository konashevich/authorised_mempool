# Addressing Sanctioned and Unethical Validators in Public Blockchain Applications

**Oleksii Konashevych, PhD**  
oleksii@konashevych.com

**Abstract.** Governments exploring public blockchain infrastructure face a critical challenge: ensuring that transaction processing does not inadvertently reward sanctioned or unethical validators. This paper proposes a dual-tier enforcement mechanism designed to reconcile the openness of permissionless networks with strict regulatory compliance. Employing Design Science Research (DSR) methodology, we introduce an "IT artifact" comprising (1) an infrastructure-level authorised transaction submission channel and (2) an application-level smart contract whitelist. This architecture ensures that sanctioned entities are technically and economically excluded from participating in government-regulated applications, demonstrating that control over applications does not require control over the underlying infrastructure. Crucially, the system imposes an immediate economic penalty on non-compliant usage: transactions routed through unauthorised validators are automatically reverted, causing the sender to forfeit gas fees without achieving the asset transfer.

**Keywords:** Public Blockchain, Ethereum, Ethereum Virtual Machine, Sanctioned Validators, Smart Contracts, Government Applications.

---

## 1 Introduction

The adoption of public permissionless blockchains (e.g., Ethereum) by government entities offers significant advantages in transparency, resilience, and interoperability. However, the open nature of these networks presents a unique compliance challenge. Unlike permissioned networks where all participants are vetted, public networks allow any entity to become a validator (block producer). This raises the possibility that government transactions—and the associated gas fees—could be processed by validators located in sanctioned jurisdictions or controlled by ethically compromised entities.

This paper addresses the research question: *How can governments leverage public blockchains without inadvertently supporting sanctioned actors?* We propose a solution that does not rely on modifying the underlying blockchain protocol but instead enforces compliance at the application and infrastructure layers.

## 2 Problem Statement

The concern regarding sanctioned validators manifests in two distinct dimensions: economic support and legitimacy.

Firstly, there is the direct financial concern. Validators earn fees for processing transactions. If a government application processes millions of transactions, a portion of those fees could flow to validators in sanctioned jurisdictions (e.g., a node operating in a sanctioned country earning ETH from a government department's contract interaction). This could potentially violate the government's own sanctions regimes or counter-terrorism financing (CTF) regulations.

Secondly, there is a reputational and ethical risk. Even if the financial value is negligible, the perception that a government is "using" infrastructure maintained by adversarial actors is politically untenable. As noted in the concept of the "Regulated Perimeter," governments must ensure that their economic flows remain strictly contained within compliant channels, avoiding any legitimacy being lent to unethical actors.

Existing literature typically offers two solutions: stick to private permissioned blockchains (sacrificing openness) or accept the risk of public chains (sacrificing control). There is a lack of mechanisms that allow for *selective* validation compliance on public networks.

## 3 Literature Review

The specific problem of "sanctioned validators" emerged prominently following the United States Treasury Department's Office of Foreign Assets Control (OFAC) designation of Tornado Cash in August 2022 [1]. This event, coinciding with Ethereum's transition to Proof-of-Stake (The Merge), crystallised the conflict between immutable blockchain protocols and national security regulations.

### 3.1 The Censorship Debate
Initial academic and industry discourse focused on the "censorship resistance" properties of the network. Research by Wahrstätter et al. (2023) highlighted that immediately post-Merge, over 60% of Ethereum blocks were produced by OFAC-compliant relays (e.g., Flashbots), which actively filtered out transactions interacting with sanctioned addresses [2]. This led to a bifurcated network state where "non-compliant" transactions could still be processed, but with significant delays, raising concerns about the neutrality of the base layer.

### 3.2 Existing Approaches
Current solutions in the literature are predominantly infrastructure-centric and binary:
1.  **Universal Filtering**: Solutions like OFAC-compliant MEV-Boost relays impose censorship at the block-building level. This is criticised for threatening the "credibly neutral" nature of the public blockchain [3].
2.  **Privacy Enhancements**: Conversely, proposals for "encrypted mempools" or "inclusion lists" aim to enforce neutrality by technically preventing validators from knowing transaction contents until after inclusion [4].

### 3.3 The Research Gap
A critical gap remains in addressing *application-specific* compliance. Existing literature largely assumes that compliance must be enforced at the network level (censoring the chain) or not at all (permissionsless). There is limited research on mechanisms that allow individual government applications to enforce their own validator selection criteria without imposing those criteria on the wider network. This paper addresses that gap.

## 4 Methodology

This research adopts the **Design Science Research (DSR)** methodology. DSR is a problem-solving paradigm that seeks to enhance human knowledge via the creation of innovative artifacts. In this context, the problem is the compliance gap in public blockchains, and the "artifact" is the proposed Dual-Tier Enforcement Mechanism.

The artifact is designed to satisfy two primary requirements: strict compliance and open infrastructure. First, the mechanism must ensure that zero fees flow to sanctioned validators, effectively cutting them off from the economic activity of the application. Second, the solution must operate on standard public blockchains without requiring protocol forks, thereby preserving the benefits of permissionless infrastructure while enforcing selective compliance.

## 5 The Artifact: Dual-Tier Enforcement Mechanism

The proposed solution relies on two mutually reinforcing mechanisms: strictly controlled transaction routing (Tier 1) and on-chain validity enforcement (Tier 2).

### 5.1 Tier 1: Authorised Transaction Submission Channel

The first tier operates off-chain at the infrastructure level. Government applications are designed to bypass the public "mempool"—the waiting area for transactions where any validator can pick them up. Instead, transactions are routed exclusively through a private submission protocol.

In this model, the government or its designates operate authenticated relayers. These relayers differ from standard nodes in that they do not "gossip" (broadcast) transactions to the public peer-to-peer network. Instead, they maintain persistent, direct Peering (TCP/IP) connections exclusively with a specific set of whitelisted validators who have proven their jurisdiction and compliance identity.

For the end-user, this requires a specific wallet configuration or DApp integration. The user's wallet (e.g., via a custom RPC endpoint) or the application interface sends the signed transaction directly to the secure relayer via an API (e.g., standard HTTP POST), bypassing the public network entirely. Consequently, sanctioned validators never observe these transactions in their local mempools and thus cannot attempt to include them in a block.

### 5.2 Tier 2: On-Chain Validator Whitelist Enforcement

While Tier 1 prevents sanctioned validators from seeing transactions under normal conditions, it is not cryptographically enforceable on its own (a transaction could accidentally leak to the public mempool). Tier 2 provides the "enforcement" via the smart contract itself.

The smart contract maintains an on-chain mapping of authorised validator addresses (specifically, the `fee recipient` or `coinbase` address). Every state-changing function in the contract includes a modifier that checks the identity of the current block producer (`block.coinbase`).

If an unauthorised (e.g., sanctioned or unknown) validator attempts to include a transaction from this application in their block, the smart contract detects that `block.coinbase` is not in the whitelist and immediately **reverts** the transaction.

The consequences of this revert are critical. Firstly, the transaction fails immediately, ensuring no state change occurs—**the token is not transferred**. Secondly, the user is still charged for the gas consumed by the execution up to the point of the revert. The non-compliant validator receives a small fee for this execution (the gas used), but the user is effectively penalised: they pay the fee but achieve nothing. This makes circumventing the authorised channel economically irrational for the user and serves as a deterrent for violating the ban to do business with sanctioned and nauthorised nodes. 

## 6 Evaluation

The proposed artifact was evaluated through a technical feasibility study using a local blockchain environment. The core premise—that a smart contract can discriminate based on the block producer's identity—was verified using the Solidity implementation provided in the Annex.

### 6.1 Simulation Results
The smart contract successfully identified the `block.coinbase` (the fee recipient) of the simulated block.
*   **Case A: Compliant Validator.** When a transaction was simulated in a block built by a whitelisted address, the transaction executed successfully, and state changes (token transfers) were committed.
*   **Case B: Non-Compliant Validator.** When the same transaction was simulated in a block built by a non-whitelisted address, the `SanctionGuard` modifier triggered a `revert`. The transaction failed, and no state changes occurred.

This confirms that the application-level enforcement mechanism functions as designed, providing a deterministic barrier against unauthorised validators.

## 7 Discussion

### 7.1 Mechanism Analysis and Economic Rationality

To understand the robustness of this solution, consider a practical scenario. A regulatory body maintains a "Validator Registry" smart contract containing a list of authorised, compliant validators. When an issuer deploys a regulated security token, they include a specific logic check: "Is the validator proposing this block on the authorised list?"

The system is designed to punish circumvention. Suppose a user tries to bypass the authorised submission channel (Tier 1) and instead broadcasts their transaction to the public network mempool. A sanctioned or unauthorised validator might pick it up and attempt to process it.

However, once the transaction is included in a block, the token's smart contract performs its check (Tier 2). It sees that the block producer is not on the regulator's whitelist. The contract immediately triggers a 'revert'.

The result is a triple-penalty for the user's error:
1.  **Transaction Published but Void:** The transaction is technically recorded on the blockchain, but the asset transfer is cancelled. The tokens never leave the user's wallet.
2.  **Fee Forfeiture:** The user is still charged the "gas fee" for the computational work done up to the point of rejection. They pay for the transaction but receive nothing in return.
3.  **Validator Disincentive:** The unauthorised validator receives only a trivial amount of gas fees for a failed transaction, rather than the full reward of a successful operation.

This mechanism ensures that the only rational way to transact is through the compliant channel, as violating the rules results in guaranteed financial loss without successful execution.

### 7.2 The Regulated Perimeter

This architecture enables what can be termed a "Regulated Perimeter" on public blockchains. The Regulated Perimeter signifies a system of whitelisted financial operators, their contracts, and customers. In other words, it establishes the due diligence and compliance framework through which both operators and customers are admitted "inside" the perimeter.

Government bodies can maintain the on-chain whitelist, effectively locking out any address suspected of violating regulations. This allows the regulator to retain absolute control over *who* processes the data, without needing to control the entire network.

### 7.3 Limitations

This approach relies on `block.coinbase` identification. In modern Ethereum architecture (Proposer-Builder Separation), the entity building the block (the Builder) and the entity proposing it (the Validator) may differ. However, as the `coinbase` address receives the priority fees, the economic penalty remains targeted at the entity intended to benefit from the block. While not a "silver bullet" for identity (addresses can be rotated), the "default-deny" whitelist ensures that any new, unknown address is automatically blocked.

## 8 Conclusion

We have presented a dual-tier mechanism that solves the seemingly intractable problem of using open, permissionless validators for regulated government applications. By combining private transaction routing with on-chain execution gating, governments can ensure their applications are processed exclusively by compliant entities. This approach demonstrates that public blockchains can support stringent regulatory requirements, provided that enforcement is built into the application design itself. Future work will focus on the development of open protocols for maintaining these authorised mempool channels, the creation of custom wallet specifications to support seamless private routing, and a comprehensive pilot deployment on the Sepolia testnet to validate the full system end-to-end.

---

## References

1.  U.S. Department of the Treasury: U.S. Treasury Sanctions Notorious Virtual Currency Mixer Tornado Cash (2022). https://home.treasury.gov/news/press-releases/jy0916
2.  Wahrstätter, A. et al.: Blockchain Censorship. arXiv preprint arXiv:2301.00000 (2023)
3.  Flashbots: The operational decentralisation of the Flashbots relay (2022). https://writings.flashbots.net/
4.  Buterin, V.: State of research: increasing censorship resistance of transactions under proposer/builder separation (PBS) (2022). https://notes.ethereum.org/
5.  Konashevych, O.: Authorised Mempool Project Repository. https://github.com/konashevich/authorised_mempool


## Annex: Smart Contract Implementation

The following Solidity code demonstrates the implementation of the Dual-Tier Enforcement Mechanism. The full project source code and maintenance updates are available at [5]. The implementation consists of three components:
1.  **ValidatorRegistry**: Management of the "Regulated Perimeter".
2.  **SanctionGuard**: The abstract enforcement module.
3.  **RegulatedToken**: An example ERC-20 token that integrates the guard to enforce compliance on every transfer.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract ValidatorRegistry is AccessControl {
    bytes32 public constant REGULATOR_ROLE = keccak256("REGULATOR_ROLE");
    mapping(address => bool) private _authorisedValidators;
    event ValidatorStatusUpdated(address indexed validator, bool isAuthorised);

    constructor(address _admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(REGULATOR_ROLE, _admin);
    }
    
    function isAuthorised(address validator) external view returns (bool) {
        return _authorisedValidators[validator];
    }

    function updateValidatorStatus(address[] calldata validators, bool status) external onlyRole(REGULATOR_ROLE) {
        for (uint256 i = 0; i < validators.length; i++) {
            _authorisedValidators[validators[i]] = status;
            emit ValidatorStatusUpdated(validators[i], status);
        }
    }
}

abstract contract SanctionGuard {
    ValidatorRegistry public immutable validatorRegistry;
    event ComplianceCheck(address indexed validator, bool success);
    error UnauthorisedValidator(address validator);

    constructor(address _registry) {
        require(_registry != address(0), "Invalid registry address");
        validatorRegistry = ValidatorRegistry(_registry);
    }

    function _checkValidatorCompliance() internal {
        address currentValidator = block.coinbase;
        if (block.chainid == 1337) return; // Skip for local testnet

        if (!validatorRegistry.isAuthorised(currentValidator)) {
            emit ComplianceCheck(currentValidator, false);
            revert UnauthorisedValidator(currentValidator);
        }
    }

    modifier onlyCompliantValidator() {
        _checkValidatorCompliance();
        _;
    }
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RegulatedToken is ERC20, Ownable, SanctionGuard {
    constructor(string memory name, string memory symbol, address _registry, address _initialOwner) 
        ERC20(name, symbol) 
        Ownable(_initialOwner) 
        SanctionGuard(_registry) 
    {
        _mint(_initialOwner, 1000000 * 10 ** decimals());
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        _checkValidatorCompliance(); // Enforce compliance on EVERY state change
        super._update(from, to, value);
    }
}
```
