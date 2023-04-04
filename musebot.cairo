%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256,uint256_add
from starkware.cairo.common.alloc import alloc
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.access.ownable.library import Ownable
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.memcpy import memcpy




@storage_var
func tokenid() -> (tokenid: Uint256) {
}

@storage_var
func token_uris(tokenid: Uint256) -> (res: felt){
}

@storage_var
func ERC721_base_tokenURI(index: felt) -> (res: felt){
}

@storage_var
func ERC721_base_tokenURI_len() -> (res: felt){
}

func concat_arr{range_check_ptr}(
        arr1_len: felt,
        arr1: felt*,
        arr2_len: felt,
        arr2: felt*,
    ) -> (res: felt*, res_len: felt){
    alloc_locals;
    let (local res: felt*) = alloc();
    memcpy(res, arr1, arr1_len);
    memcpy(res + arr1_len, arr2, arr2_len);
    return (res, arr1_len + arr2_len);
}

func ERC721_tokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(token_id: Uint256) -> (tokenURI_len: felt, tokenURI: felt*){
    alloc_locals;

    let exists= ERC721._exists(token_id);
    with_attr error_message("ERC721_Metadata: nonexistent token") {
        assert exists = TRUE;
    }

    let (local base_tokenURI) = alloc();
    let (local base_tokenURI_len) = ERC721_base_tokenURI_len.read();
    _ERC721_baseTokenURI(base_tokenURI_len, base_tokenURI);
    let (token_uri) = token_uris.read(token_id);
    let (local suffix) = alloc();
    [suffix] = token_uri;
    let (token_uristr, token_uri_len) = concat_arr(base_tokenURI_len, base_tokenURI, 1, suffix);

    return (tokenURI_len=token_uri_len, tokenURI=token_uristr);
}

func _ERC721_baseTokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(base_tokenURI_len: felt, base_tokenURI: felt*){
    if (base_tokenURI_len == 0){
        return ();
    }
    let (base) = ERC721_base_tokenURI.read(base_tokenURI_len);
    assert [base_tokenURI] = base;
    _ERC721_baseTokenURI(base_tokenURI_len=base_tokenURI_len - 1, base_tokenURI=base_tokenURI + 1);
    return ();
}


func ERC721_setBaseTokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenURI_len: felt, tokenURI: felt*){
    _ERC721_setBaseTokenURI(tokenURI_len, tokenURI);
    ERC721_base_tokenURI_len.write(tokenURI_len);
    return ();
}


func _ERC721_setBaseTokenURI{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(tokenURI_len: felt, tokenURI: felt*){
    if (tokenURI_len == 0){
        return ();
    }
    ERC721_base_tokenURI.write(index=tokenURI_len, value=[tokenURI]);
    _ERC721_setBaseTokenURI(tokenURI_len=tokenURI_len - 1, tokenURI=tokenURI + 1);
    return ();
}


//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        owner: felt,
        tokenURI_len: felt,
        tokenURI: felt*
) {
    ERC721.initializer('MuseBotAI', 'MuseBotAI');
    Ownable.initializer(owner);
    ERC721_setBaseTokenURI(tokenURI_len, tokenURI);
    return ();
}

//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    let (name) = ERC721.name();
    return (name,);
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    let (symbol) = ERC721.symbol();
    return (symbol,);
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    let (balance: Uint256) = ERC721.balance_of(owner);
    return (balance,);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (owner: felt) {
    let (owner: felt) = ERC721.owner_of(token_id);
    return (owner,);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (approved: felt) {
    let (approved: felt) = ERC721.get_approved(token_id);
    return (approved,);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (is_approved: felt) {
    let (is_approved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (is_approved,);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (tokenURI_len: felt, tokenURI: felt*) {
    let (tokenURI_len: felt, tokenURI: felt*) = ERC721_tokenURI(token_id);
    return (tokenURI_len=tokenURI_len, tokenURI=tokenURI);
}

@view
func tokenSelfURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (tokenURI: felt) {
    let (token_uri) = token_uris.read(token_id);
    return (token_uri,);
}

//
// Externals
//

@external
func setTokenBaseURI{
        pedersen_ptr: HashBuiltin*,
        syscall_ptr: felt*,
        range_check_ptr
    }(tokenURI_len: felt, tokenURI: felt*){
    Ownable.assert_only_owner();
    ERC721_setBaseTokenURI(tokenURI_len, tokenURI);
    return ();
}

func _set_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(token_id: Uint256, token_uri: felt) {
    token_uris.write(token_id,token_uri);
    return ();
}

@external
func mintOne{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        to: felt,token_uri: felt
    ) -> (res: Uint256) {
    let token_id: Uint256 = tokenid.read();
    ERC721._mint(to, token_id);
    _set_token_uri(token_id,token_uri);
    let (res,_) = uint256_add(token_id,Uint256(1,0));
    tokenid.write(res);
    return (res,);
}

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, token_id: Uint256
) {
    ERC721.approve(to, token_id);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256
) {
    ERC721.transfer_from(_from, to, token_id);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, to: felt, token_id: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(_from, to, token_id, data_len, data);
    return ();
}
