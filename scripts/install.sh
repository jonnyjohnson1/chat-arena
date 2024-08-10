#!/bin/bash

# Step 1: Download GitHub repo
echo "Step 1: Downloading GitHub repository..."
git clone https://github.com/jonnyjohnson1/topos-cli
cd topos-cli

# Step 2: Check if poetry exists and build
if command -v poetry &> /dev/null
then
    echo "Poetry exists. Building with Poetry..."
    poetry build
else
    echo "Poetry not found. Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python -
    export PATH="$HOME/.local/bin:$PATH"
    echo "Building with Poetry..."
    poetry build
fi

# Step 3: Install the package
echo "Step 3: Installing the package..."
pip install .

echo "Topos package installed!"

# Step 4: Set the spacy trf
which topos
echo "Step 4: Downloading spacy model..."
topos set --spacy trf

echo "Installation complete!"