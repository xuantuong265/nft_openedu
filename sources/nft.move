module nft::nft {
  use sui::object;
  use std::string;
  use sui::url;
  use sui::tx_context;
  use sui::transfer;

  struct WALLNFT has key, store {
    id: object::UID,
    name: string::String,
    link: url::Url,
    image_url: url::Url,
    description: string::String,
    creator: string::String,
  }

  public fun mint(
    _name: vector<u8>,
     _link: vector<u8>, 
     _image_url: vector<u8>, 
     _description: vector<u8>, 
     _creator: vector<u8>,
      ctx: &mut tx_context::TxContext
  ): WALLNFT {
    WALLNFT {
      id: object::new(ctx),
      name: string::utf8(_name),
      link: url::new_unsafe_from_bytes(_link),
      image_url: url::new_unsafe_from_bytes(_image_url),
      description: string::utf8(_description),
      creator: string::utf8(_creator),
    }
  }

  public fun update_name(nft: &mut WALLNFT, _name: vector<u8>) {
    nft.name = string::utf8(_name);
  }

  public fun update_link(nft: &mut WALLNFT, _link: vector<u8>) {
    nft.link = url::new_unsafe_from_bytes(_link)
  }

  public fun update_image_url(nft: &mut WALLNFT, _image_url: vector<u8>) {
    nft.image_url = url::new_unsafe_from_bytes(_image_url)
  }

  public fun update_creator(nft: &mut WALLNFT, _creator: vector<u8>) {
    nft.creator = string::utf8(_creator)
  }

  public fun update_descrition(nft: &mut WALLNFT, _description: vector<u8>) {
    nft.description = string::utf8(_description);
  }

  public fun get_link(nft: &WALLNFT): &url::Url {
    &nft.link
  }

  public fun get_name(nft: &WALLNFT): &string::String {
    &nft.name
  }

  public fun get_image_url(nft: &WALLNFT): &url::Url {
    &nft.image_url
  }

  public fun get_creator(nft: &WALLNFT): &string::String {
    &nft.creator
  }

  public fun get_description(nft: &WALLNFT): &string::String {
    &nft.description
  }

  #[test_only]
  public fun mint_for_test(
    name: vector<u8>,
    link: vector<u8>,
    image_url: vector<u8>,
    description: vector<u8>,
    creator: vector<u8>,
    ctx: &mut tx_context::TxContext
  ): WALLNFT {
    mint(name, link, image_url, description, creator, ctx)
  }
}

#[test_only]
module nft::nft_for_test {
  use nft::nft::{Self, WALLNFT};
  use sui::test_scenario::{Self as ts};
  use sui::transfer;
  use std::string;
  use sui::url;

  #[test]
  fun mint_test() {
    let address_1 = @0xA;
    let address_2 = @0xB;

    let scenario = 
      ts::begin(address_1);
      {
        let nft = nft::mint_for_test(
          b"name",
          b"link",
          b"image link",
          b"description",
          b"creator",
          ts::ctx(&mut scenario)
        );
        transfer::public_transfer(nft, address_1);
      };
      ts::next_tx(&mut scenario, address_1);
      {
        let nft = ts::take_from_sender<WALLNFT>(&mut scenario);
        transfer::public_transfer(nft, address_2);
      };
      ts::next_tx(&mut scenario, address_2);
      {
        let nft = ts::take_from_sender<WALLNFT>(&mut scenario);

        nft::update_name(&mut nft, b"new name");
        nft::update_link(&mut nft, b"new link");
        nft::update_image_url(&mut nft, b"new image url");
        nft::update_creator(&mut nft, b"new creator");
        nft::update_descrition(&mut nft, b"new description");

        assert!(*string::bytes(nft::get_name(&nft)) == b"new name", 0);
        assert!(*nft::get_link(&nft) == url::new_unsafe_from_bytes(b"new link"), 0);
        assert!(*nft::get_image_url(&nft) == url::new_unsafe_from_bytes(b"new image url"), 0);
        assert!(*string::bytes(nft::get_creator(&nft)) == b"new creator", 0);
        assert!(*string::bytes(nft::get_description(&nft)) == b"new description", 0);

        ts::return_to_sender(&mut scenario, nft);
      };
      ts::end(scenario);
  }
}
