#!/bin/bash
sudo apt update
sudo apt install -y build-essential libboost-all-dev
git clone https://github.com/eehlers/QuantLibXL.git
cd QuantLibXL
