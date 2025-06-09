{ lib, ... }:

let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);

  flattenList = name: lst:
    lib.listToAttrs (lib.genList (idx:
      let val = builtins.elemAt lst idx;
      in {
        name = "${name}_API_KEY_${toString (idx + 1)}";
        value = val;
      }) (builtins.length lst) # The length of the list to generate.
    );

  flattenSecrets = secrets:
    lib.concatMapAttrs (key: val:
      if lib.isList val then
        flattenList key val
      else
        throw "Value of ${key} must be a list, got ${builtins.typeOf val}")
    secrets;

in flattenSecrets secrets
