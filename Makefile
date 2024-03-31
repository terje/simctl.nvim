.PHONY: test

test:
	nvim --headless -c 'PlenaryBustedDirectory lua/simctl/ {}' -c 'qa!'
