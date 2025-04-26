module nfttest::cap;


// === Structs ===
public struct AdminCap has key,store {
  id: UID,
}

// ===Initilization ===

fun init(ctx: &mut TxContext){
  let admin_cap = AdminCap{
    id: object::new(ctx),
  };
  transfer::public_transfer(admin_cap, ctx.sender());
}

// === Public Functions ===

public fun burn_cap(cap: AdminCap){
  let AdminCap{id} = cap;
  id.delete();
}