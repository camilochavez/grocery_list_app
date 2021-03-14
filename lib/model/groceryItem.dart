class GroceryItem {
  int _id;
  String _name;
  int _priority;
  int _quantity;
  int _price;
  bool _isBought;

  GroceryItem(this._name,
      [this._quantity = 0,
      this._priority = 1,
      this._isBought = false,
      this._price = 0]);
  GroceryItem.withId(this._id, this._name,
      [this._quantity = 0,
      this._priority = 1,
      this._isBought = false,
      this._price = 0]);

  int get id => _id;
  String get name => _name;
  int get priority => _priority;
  // ignore: unnecessary_getters_setters
  int get quantity => _quantity;
  int get price => _price;
  // ignore: unnecessary_getters_setters
  bool get isBought => _isBought;

  set name(String newName) {
    if (newName.length <= 255) {
      _name = newName;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 0 && newPriority <= 3) {
      _priority = newPriority;
    }
  }

  // ignore: unnecessary_getters_setters
  set quantity(int newQuantity) => _quantity = newQuantity;

  set price(int newPrice) => _price = _price = newPrice;
  // ignore: unnecessary_getters_setters
  set isBought(bool newIsBought) => _isBought = newIsBought;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["name"] = _name;
    map["quantity"] = _quantity;
    map["priority"] = _priority;
    map["price"] = _price;
    map["isBought"] = _isBought ? 1 : 0;
    if (_id != null) {
      map["id"] = _id;
    }
    return map;
  }

  GroceryItem.fromObject(dynamic o) {
    this._id = o["id"];
    _name = o["name"];
    _quantity = o["quantity"];
    _priority = o["priority"];
    _price = o["price"];
    _isBought = o["isBought"] == 1 ? true : false;
  }

  GroceryItem.fromJson(Map<String, dynamic> json)
      : _name = json["name"],
        _quantity = json["quantity"],
        _priority = json["priority"],
        _price = json["price"],
        _isBought = json["isBought"] == 1 ? true : false;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'priority': priority,
        'price': price,
        'isBought': isBought ? 1 : 0
      };
}
