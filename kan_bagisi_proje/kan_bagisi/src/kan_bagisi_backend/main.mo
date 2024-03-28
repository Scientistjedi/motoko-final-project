import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";  //bütün bilgiler tek listede toparlanıyor
import Option "mo:base/Option";
import List "mo:base/List";
import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";




//akıllı sözleşmeyi açtık actor
actor KanBagisi {

  public type DonorId = Nat32;

  public type DonorCheck = {
    description: Text;
    completed: Bool;


  };

  public type DonorInfo = {

    name: Text; //bağışçı ismi soyismi
    surname: Text;
    phone: List.List<Text>;
    chronic_disease: List.List<Text>; // kronik hastalıklar liste olarak iletsin
    blood_type: List.List<Text>; // kan tipi liste olarak iletsin

  };

  private stable var next: DonorId = 0; 

  private stable var donors: Trie.Trie<DonorId, DonorInfo> = Trie.empty(); 

  // yüksek seviye API yapacağız

  public func create_donor_infos(donor: DonorInfo) : async DonorId {
    let donorId = next;
    next += 1;
    donors := Trie.replace(
      donors,
      key(donorId),
      Nat32.equal,
      ?donor,
    ).0;
    donorId

  };

  public query func readDonorInfo(donorId: DonorId) : async ?DonorInfo {

    let result = Trie.find(donors, key(donorId), Nat32.equal);
    result
  };

  public func update_donor_infos(donorId: DonorId, donor: DonorInfo): async Bool { //update var mı superherolara bakmak için
    let result = Trie.find(donors, key(donorId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {

      donors := Trie.replace(

        donors,
        key(donorId),
        Nat32.equal,
        ?donor,
      ).0;
    };
    exists
  };


 func natHash(n: Nat) : Hash.Hash {
    Text.hash(Nat.toText(n))


  }; //doğal sayılar hashlensin fonksiyonu
  
   var donorcheck = Map.HashMap<Nat, DonorCheck>(0, Nat.equal, natHash);
   var nextId: Nat = 0;

   public query func getDonorCheck() : async [DonorCheck] {  //gelen bilgileri array olarak döndüdr
    Iter.toArray(donorcheck.vals());



  };

  public func add_donor_name_surname(description: Text) : async Nat {
    let id = nextId;
    donorcheck.put(id, {description = description; completed = false});
    nextId += 1;
  
    id // return id; de denebilir

  };
public query func showDonorList() : async Text { // # in anlamı yazılı ifade demek
    var output: Text = "\n_______DONOR NAMES__________";

    for (todo: DonorCheck in donorcheck.vals()) {
      output #= "\n" # todo.description;
      if (todo.completed) {  output #= " +" };


    };
    output # "\n"
    

  };

  public func completeDonor(id: Nat) : async () { // id check et tamamlanmadıysa ignore et
    ignore do ? {
      let description = donorcheck.get(id)!.description;  // ! işareti ignore u gösteriyor değil demek yani
      donorcheck.put(id, {description; completed = true});


    }
  };

  public func delete_donor_info(donorId: DonorId): async Bool {
    let result = Trie.find(donors, key(donorId), Nat32.equal);
    let exists = Option.isSome(result);
    if (exists) {

      donors := Trie.replace(
        donors,
        key(donorId),
        Nat32.equal,
        null,
      ).0;
    };
    exists

  };
//key oluşturacağız
  private func key(x: DonorId): Trie.Key<DonorId> {
    { hash = x; key = x };


  };



};
