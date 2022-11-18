# What is the build and directory structure of the stacks-network repo?

Repository Location
[https://github.com/stacks-network/stacks-blockchain](https://github.com/stacks-network/stacks-blockchain)

Branches
- master
- next
- develop

Cargo package structure
- Top-level virtual manifest

# How do I run test cases?

## Local tests

```
cargo test --release --workspace -- --report-time -Z unstable-options
```

## CI (ignored) tests
- Download Bitcoin https://bitcoin.org/bin/bitcoin-core-0.20.0/
```
PATH=$PATH:/path-to/bitcoin-22.0/bin
BITCOIND_TEST=1
cargo test -p stacks-node -- --ignored "tests::neon_integrations::miner_submit_twice"
```

# What are the test environments? mainnet/testnet, neon/krypton, and helium/mocknet

Run Loops
Neon
Real burnchain.
Helium
Simulated burnchain and some simulated nodes taking turns in producing blocks.

Do not confuse burnchain modes neon and helium with run loops neon and helium.

How do I run a mock miner?

What is testnet?

What is sortition?

What are tenures?

What are epochs?

What are reward cycles?

What is PoX anchor block?

What is anchor block?

How is PoX anchor block different from anchor block?

What is index block hash vs block hash?

What is a microblock?

What sqlite db’s does stacks-node use?

Sortition DB
working_dir/mainnet/burnchain/sortition
Chainstate DB
working_dir/mainnet/chainstate
TODO

How do I explore the sqlite db’s?
Install sqlite:
Mac: brew install sqlite



What threads does stacks-node spawn?
Relayer thread
Miner thread
Chains coordinator
TODO: list all threads under each run loop mode

What are the typical log file entries for stacks-node?
TODO: list frequency of log lines during bootstrap and during normal running conditions

What are affirmation maps?
PoX affirmation maps
https://gist.github.com/jcnelson/b1aa4bef8b9adb0856b28d3a933ef9a0
https://github.com/stacks-network/stacks-blockchain/pull/2707


Where can I learn more?
Stacks 2.0 Internals
 https://github.com/stacks-network/docs


Clarity Development
How do I check the syntax of a Clarity smart contract?
Install clarinet
From a mac: brew install clarinet
From source: https://github.com/hirosystems/clarinet
Use clarinet to check the contract:
clarinet check src/chainstate/stacks/boot/pox-2.clar