# 0.027 in eth minimum
# 27000000000000000 in wei
from brownie import accounts, Lottery, config, network
from web3 import Web3
from dotenv import load_dotenv
import os
load_dotenv()
contract = ''


def test_minimumFee():
    print(network.show_active())
    
    requestid = 0
    contract = Lottery.deploy(config['networks'][network.show_active()]['priceFeed'], {
                            'from': accounts.add(os.getenv('PRIVATE_KEY'))})
    fee = contract.getEntranceFee()
    print(fee)
    requestid = contract.requestRandomWords({'from':accounts.add(os.getenv('PRIVATE_KEY')), 'gas_limit':500000})
    assert fee > Web3.toWei(0.025, 'ether')
    assert fee < Web3.toWei(0.029, 'ether')
    assert requestid!=0
    
    



def main():
    test_minimumFee()
