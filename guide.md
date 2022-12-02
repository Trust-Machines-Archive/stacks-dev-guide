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

## How do I get testnet STX coins from the faucet?

Visit https://explorer.stacks.co/sandbox/faucet?chain=testnet 

The chain=testnet will configure testnet mode and also a url for the public testnet. The Networks tab can be used to add any url for an alternate stacks network. This was done for Stacks 2.1 testing because it was a hard-fork.

## How do I stack stx from the commandline?

Pre-reqs
- a stacks account
- blockstack-cli
  - built from stacks-blockchain sources
- base58 decoder
  - https://appdevtools.com/base58-encoder-decoder

Generate the transaction. stack-stx function signature from See pox-2.clar.

  (stack-stx (amount-ustx uint)
             (pox-addr (tuple (version (buff 1)) (hashbytes (buff 32))))
             (start-burn-ht uint) ; must be a burn block height inside the next reward cycle
             (lock-period uint)) ; number of reward cycles to lock for

note on pox-addr: version values are in pox-2.clar. p2pkh = 1 (legacy address. 20 byte hashbytes). hashbytes come from base58 decoding the bitcoin address to a 25 byte/50 char hex string and removing the leading version byte and the four trailing checksum bytes. 

```
blockstack-cli --testnet contract-call <66 byte stx private key in hex> 300 3 ST000000000000000000002AMW42H pox-2 stack-stx 
                -e u5160000000000 -e '{version: 0x01, hashbytes: 0xe8b19d771ed4f3ab18dd5c8cc6fca3a2a1c31b61}' -e u2409274 -e u1  > tx.json
```

Convert hex to binary and post to API URL /v2/transactions

```
cat tx.json | xxd -r -p | curl --data-binary @- -H "content-type: application/octet-stream" http://2-1-seed.testnet.hiro.so:20443/v2/transactions
```

Output is the tx id on success
"0b4774132f3252dfc242a05178691eb06c98fb5e8295917e67e501f9d44764e2"

## How do I make a call to a read-only function in a clarity contract?

Because a call to a read-only function can be done instantly by any node and does not create a new transaction, it can be done with a siple http request. The payload specifies the stx address that is making the call to the function, and the arguments array contains strings of each serialized clarity value for each function parameter.

One way to generate the serialized clarity value is to use https://github.com/jcnelson/stacks-node-cli and the encode function there.

```
curl https://2-1-api.testnet.hiro.so/v2/contracts/call-read/ST000000000000000000002AMW42H/pox-2/get-total-ustx-stacked -d '{"sender":"ST3MB37BQ3VAF7ARRVNE8SHQWMEHA3GRVC6QCSB7M", "arguments": ["0100000000000000000000000000000001"]}' -H "content-type: application/json" => {"okay":true,"result":"0x0100000000000000000000000000000000"}
```

## How do I get the hashbytes for a pox-addr from bitcoin compressed public key bytes?

btc public Key (compressed, 1 even/odd marker plus 32 bytes. 66 hex characters): 02048D1783065CE86FAE4B2DC67B9455EFF8B0D1F5D3BB63E9E2FFDDB4A921970D
```
$ echo 02048D1783065CE86FAE4B2DC67B9455EFF8B0D1F5D3BB63E9E2FFDDB4A921970D  | xxd -r -p | sha256sum
be6f7f08c8c8d0ff9cb47483a7d24bc984e4381c0057b7b16c315f212c46f0a0  -
$ cargo install digester --all-features
$ echo be6f7f08c8c8d0ff9cb47483a7d24bc984e4381c0057b7b16c315f212c46f0a0  | xxd -r -p |  digester -a ripemd160
e8b19d771ed4f3ab18dd5c8cc6fca3a2a1c31b61
```


