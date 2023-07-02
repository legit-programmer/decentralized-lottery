#0.027 in eth minimum
# 27000000000000000 in wei
from brownie import accounts, Lottery, config, network, VRFv2DirectFundingConsumer
from web3 import Web3

def test_minimumFee():
    print(network.show_active())
    contract = Lottery.deploy(config['networks'][network.show_active()]['priceFeed'], {'from':accounts[0]})
    fee= contract.getEntranceFee()
    print(fee)
    assert fee > Web3.toWei(0.025, 'ether')
    assert fee < Web3.toWei(0.029, 'ether')

def test_randomWords():
    contract = VRFv2DirectFundingConsumer.deploy({'from':accounts[0]})
    requestid = contract.requestRandomWords({'from':accounts[0], 'gas_limit': 100000})
    assert requestid!=0


def main():
    test_minimumFee()