.PHONY: test

test:
	nvim --headless -c "PlenaryBustedDirectory spec/ {minimal_init=vimrc}" -c "qa"
