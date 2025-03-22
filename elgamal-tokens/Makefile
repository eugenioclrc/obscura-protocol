CIRCUITS := helloworld mint transfer transfer_to_new
BUILD_DIR := circuits
SRC_DIR := src

.PHONY: all clean $(CIRCUITS)

all: $(CIRCUITS)

$(CIRCUITS):
	cd $(BUILD_DIR)/$@ && nargo build
	echo "$(BUILD_DIR)/$@/target/$@.json"
	cd $(BUILD_DIR)/$@ && bb write_vk -b ./target/$@.json
	cd $(BUILD_DIR)/$@ && bb contract
	cp $(BUILD_DIR)/$@/target/contract.sol $(SRC_DIR)/verifiers/$@UltraVerifier.sol
	cp $(BUILD_DIR)/$@/target/$@.json ../frontend/static/circuits/

clean:
	rm -rf $(BUILD_DIR)/*/target/*.json $(BUILD_DIR)/*/target/*.sol ../frontend/static/circuits/*.json
