Turn on the `Custom Data` flag.
     ![alt text](./images/5_b_1b_whitelist_operator_with_call_data_1.png)

Generate the call data for function to white list an operator ```add_multiple(address[])``` by running:

```bash
cast calldata "add_multiple(address[])" "[<OPERATOR_ADDRESS>, ...]"
```

For example:
```bash
cast calldata "add_multiple(address[])" "[0x0000000000000000000000000000000000000009, 0x0000000000000000000000000000000000000003]"
```
will display ```0x6c7089040000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000003```

Confirm the calldata starts with the correct function identifier ```0x6c708904```.

In `Data` field paste the previously generated call data. Also check the `To Address` is the correct `registryCoordinator` address, and the `ETH value` should be set to `0`.

   ![alt text](./images/5_b_1b_whitelist_operator_with_call_data_2.png) 
