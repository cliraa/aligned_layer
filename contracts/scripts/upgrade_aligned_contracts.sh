#!/bin/bash

if [ -z "$MULTISIG" ]; then
  echo "Missing MULTISIG env variable"
  exit 1
fi
if [ -z "$OUTPUT_PATH" ]; then
  echo "Missing OUTPUT_PATH env variable"
  exit 1
fi
if [ -z "$EXISTING_DEPLOYMENT_INFO_PATH" ]; then
  echo "Missing EXISTING_DEPLOYMENT_INFO_PATH env variable"
  exit 1
fi
if [ -z "$RPC_URL" ]; then
  echo "Missing RPC_URL env variable"
  exit 1
fi
if [ -z "$PRIVATE_KEY" ]; then
  echo "Missing PRIVATE_KEY env variable"
  exit 1
fi

# cd to the directory of this script so that this can be run from anywhere
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

cd ../

# Save the output to a variable to later extract the address of the new deployed contract
forge_output=$(forge script script/upgrade/AlignedLayerUpgrader.s.sol \
    $EXISTING_DEPLOYMENT_INFO_PATH \
    $OUTPUT_PATH \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --sig "run(string memory eigenLayerDeploymentFilePath, string memory alignedLayerDeploymentFilePath, )")

echo "$forge_output"

# Extract the alignedLayerServiceManagerImplementation value from the output
aligned_layer_service_manager=$(echo "$forge_output" | awk '/0: address/ {print $3}')
new_aligned_layer_service_manager_implementation=$(echo "$forge_output" | awk '/1: address/ {print $3}')

# Use the extracted value to replace the alignedLayerServiceManagerImplementation value in alignedlayer_deployment_output.json and save it to a temporary file
jq --arg new_aligned_layer_service_manager_implementation "$new_aligned_layer_service_manager_implementation" '.addresses.alignedLayerServiceManagerImplementation = $new_aligned_layer_service_manager_implementation' $OUTPUT_PATH > "script/output/holesky/alignedlayer_deployment_output.temp.json"

# Replace the original file with the temporary file
mv "script/output/holesky/alignedlayer_deployment_output.temp.json" $OUTPUT_PATH

data=$(cast calldata "upgrade(address, address)" $aligned_layer_service_manager $new_aligned_layer_service_manager_implementation)

echo "The new AlignedLayerServiceManager Implementation is $new_aligned_layer_service_manager_implementation"

if [ "$MULTISIG" = false ]; then
  echo "Executing upgrade transaction"
  proxy_admin=$(jq -r '.addresses.alignedLayerProxyAdmin' $OUTPUT_PATH)
  cast send $proxy_admin $data \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY
else
  echo "You can propose the upgrade transaction with the multisig using this calldata"
  echo $data
fi
