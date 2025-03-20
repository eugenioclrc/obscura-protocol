cd circuits/helloworld
bb write_vk -b ./target/helloworld.json
bb contract
cp ./target/contract.sol ../../src/HelloworldUltraVerifier.sol
cd ../../