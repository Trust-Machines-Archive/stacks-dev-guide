# Stacks Developer Guide

## What is the structure of the stacks-network repo?

[https://github.com/stacks-network/stacks-blockchain](https://github.com/stacks-network/stacks-blockchain)

Branches

- `master` - For hotfixes, branch off of master.
- `next` - For consensus breaking changes, branch off of the next branch.
- `develop` - For typical development, branch off of the develop branch.

Cargo packages

| Package Name | Cargo file location | Description
| --- | --- | ---
| `blockstack-core` | `/Cargo.toml` |
| `clarity` | `/clarity/Cargo.toml` |
| `stacks-node` | `/testnet/stacks-node/Cargo.toml` |
| `stacks-common` | `/stacks-common/Cargo.toml` |
| `stx-genesis` | `/stx-genesis/Cargo.toml` |
| `puppet-chain` | `/tools/puppet-chain/Cargo.toml` |

## How do I run the test suite?

### Local tests

```
cargo test --release --workspace -- --report-time -Z unstable-options
```

### Integration tests

- Download Bitcoin <https://bitcoin.org/bin/bitcoin-core-0.20.0/>
- The list of integration tests is here: <https://github.com/stacks-network/stacks-blockchain/blob/master/.github/workflows/bitcoin-tests.yml#L41>
- All integration tests are tagged with `#[ignore]`

```
PATH=$PATH:/path-to/bitcoin-22.0/bin
BITCOIND_TEST=1
cargo test -p stacks-node -- --ignored "tests::neon_integrations::miner_submit_twice"
```

## What are the different burnchain modes and run loops?

| Burnchain Mode | Run Loop | Bitcoin Network | Nickname | Notes |
| --- | --- | --- | --- | ---
| mainnet | Neon | mainnet | mainnet
| xenon | Neon | testnet | testnet
| neon | Neon | regtest | local
| krypton | Neon | regtest | regtest
| mocknet | Helium | regtest | mocknet
| helium | Helium | regtest |
| argon | Neon | regtest | | Unsupported by stacks-node

- Run Loops
  - Neon - Uses a real burnchain node (Bitcoin)
  - Heium - Simulated burnchain and some simulated nodes taking turns in producing blocks.

Do not confuse burnchain modes **neon** and **helium** with run loops **Neon** and **Helium**.

## How do I run a mock miner?

## What is testnet?

## What is sortition?

## What are tenures?

## What are epochs?

## What are reward cycles?

## What is PoX anchor block?

## What is anchor block?

## How is PoX anchor block different from anchor block?

## What is index block hash vs block hash?

## What is a microblock?

## What databases does stacks use?

Database file location are relative to `working_directory/mainnet`

| Database file location | Description
| --- | ---
| chainstate/estimates/fee_estimator_scalar_rate.sqlite | 
| chainstate/estimates/cost_estimator_pessimistic.sqlite | 
| chainstate/vm/index.sqlite | 
| chainstate/vm/clarity/marf.sqlite | 
| chainstate/mempool.sqlite | 
| headers.sqlite | 
| atlas.sqlite | 
| peer.sqlite | 
| burnchain/burnchain.sqlite | 
| burnchain/sortition/marf.sqlite | 

## How do I explore the sqlite db’s?

- Install sqlite:
  - Mac: brew install sqlite
- Run `sqlite3 mainnet/peer.sqlite`

## What threads does stacks-node spawn?

- Relayer thread
- Miner thread
- Chains coordinator

## What are the typical log file entries for stacks-node?

TODO: list frequency of log lines during bootstrap and during normal running conditions

## What are affirmation maps?

PoX affirmation maps

- <https://gist.github.com/jcnelson/b1aa4bef8b9adb0856b28d3a933ef9a0>
- <https://github.com/stacks-network/stacks-blockchain/pull/2707>

## Where can I learn more about Stacks internals?

Stacks 2.0 Internals <https://github.com/stacks-network/docs>

## How do I check the syntax of a Clarity smart contract?

- Install clarinet
  - From a mac: brew install clarinet
  - From source: <https://github.com/hirosystems/clarinet>
- Use clarinet to check the contract: `clarinet check src/chainstate/stacks/boot/pox-2.clar`

## What is the difference between `src/vm_clarity` and `clarity/src`?

The `clarity` directory is the Clarity VM, and it does not depend on any of the Stacks-specific data storage logic.  Instead, it defines the traits for a data storage system.  This is important, because the data store Stacks uses is bespoke and somewhat large and complex in order to efficiently deal with blockchain forks (it's described in SIP-004 if you're curious).  The `clarity_vm` directory contains the implementation for these traits that links the Clarity VM to Stacks' data store. This way, you can build clarity without building the Stacks blockchain.  This gets used to build clarinet for example.
