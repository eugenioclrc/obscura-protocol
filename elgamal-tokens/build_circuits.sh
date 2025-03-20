cd circuits/helloworld
nargo build
bb write_vk -b ./target/helloworld.json
bb contract
cp ./target/contract.sol ../../src/HelloworldUltraVerifier.sol
cd ../../