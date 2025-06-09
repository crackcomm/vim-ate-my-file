{ pself }:

with pself;
buildPythonPackage rec {
  pname = "synchronicity";
  version = "0.9.12";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1f1gg6r3kigpilzd6cgm2gcshfql6x4yxbphlg8y8pg3yvc3wzwp";
  };

  nativeBuildInputs = [ hatchling ];

  propagatedBuildInputs = [ sigtools typing-extensions ];

  meta = {
    description =
      "Export blocking and async library versions from a single async implementation";
    homepage = "";
    license = lib.licenses.asl20;
  };
}
