- Set RPC URL and private key

```bash
export RPC_URL=...
export PRIVATE_KEY=....
```

- Deploy contract

```bash
 forge create NFT --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --constructor-args "MY NFT" "MNFT"
```

- Mint token 0

```bash
cast send --rpc-url=$RPC_URL 0x4dFCD6F6563CcA69C350AA8A2d2B8e7fFBff56d8  "mintTo(address)" 0xB370092982cD3eA334032a53326F57565D55a793  --private-key=$PRIVATE_KEY
```

- Check owner of token 0

```bash
cast call --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY 0x4dFCD6F6563CcA69C350AA8A2d2B8e7fFBff56d8  "ownerOf(uint256)" 0
```
