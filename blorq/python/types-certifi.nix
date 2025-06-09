{ pself }:

with pself;
buildPythonPackage rec {
  pname = "types-certifi";
  version = "2021.10.8.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ksaan5yha5r4d2nc7f288y0diwp63md23f1w5v0pg35s6c7gkvj";
  };

  nativeBuildInputs = [ setuptools wheel ];

  propagatedBuildInputs = [ ];

  meta = {
    description = "Typing stubs for certifi";
    homepage = "https://github.com/python/typeshed";
    license = lib.licenses.asl20;
  };
}
