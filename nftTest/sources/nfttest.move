/// Module: nfttest
module nfttest::nfttest;



// === Imports ===
use std::string::String;
use sui::{display, package, balance::{Self, Balance}, sui::SUI, coin::{Coin}, event};

use nfttest::cap::{AdminCap};

// === Errors ===
const ENotEnoughBalance: u64 = 0;
// === Constants ===
const NFT_MINT_COST: u64 = 100_000_000;

// === Structs ===

public struct NFT has key, store{
  id: UID,
  name: String,
  description: String,
  url: String,
}

public struct Treasury<phantom T> has key, store{
  id: UID,
  balance:Balance<T>,
  nft_mint_cost:u64,
}

// === Witnesses ===
public struct NFTTEST has drop {}

// === Events ===

public struct MintNFTEvent has copy, drop {
  id:ID,
  name:String,
  description:String,
  url:String,
}

// === Method Aliases ===

// ===Initilization ===

fun init(otw: NFTTEST, ctx: &mut TxContext){

let publisher = package::claim(otw, ctx);

let mut display = display::new<NFT>(&publisher, ctx);

display.add(b"name".to_string(), b"#{name}".to_string());
display.add(b"description".to_string(), b"{description}".to_string());
display.add(b"image_url".to_string(), b"{url}".to_string());

display.update_version();

let treasury = Treasury<SUI>{
  id: object::new(ctx),
  balance: balance::zero(),
  nft_mint_cost: NFT_MINT_COST,
};

//Transfer
transfer::public_transfer(display, ctx.sender());
transfer::public_transfer(publisher, ctx.sender());
transfer::share_object(treasury);

}

// === Public Functions ===
#[allow(lint(self_transfer))]
public fun mint_nft(treasury: &mut Treasury<SUI>, mut coin: Coin<SUI>, name:String, description:String, url:String, ctx: &mut TxContext):NFT{

assert!(coin.value() >= treasury.nft_mint_cost, ENotEnoughBalance);

treasury.balance.join(coin.split(treasury.nft_mint_cost, ctx).into_balance());

if(coin.value()==0){
  coin.destroy_zero();
}else{
  transfer::public_transfer(coin, ctx.sender());
};
let nft = NFT{
  id: object::new(ctx),
  name: name,
  description: description,
  url: url,
};

event::emit(MintNFTEvent{
  id: object::id(&nft),
  name: name,
  description: description,
  url: url,
});
nft
}

// === View Functions ===

// === Admin Functions ===
public fun set_nft_mint_cost(_:&mut AdminCap,treasury: &mut Treasury<SUI>, new_cost:u64){
  treasury.nft_mint_cost = new_cost;
}
#[allow(lint(self_transfer))]
public fun withdraw_all_the_funds(_:&mut AdminCap,treasury: &mut Treasury<SUI>, ctx: &mut TxContext){
  let value = treasury.balance.value();
  let coin = treasury.balance.split(value).into_coin(ctx);
  transfer::public_transfer(coin, ctx.sender());
}

// === Package Functions ===

// === Private Functions ===

// === Test Functions ===